---
name: ai-plan-do
description: Thực hiện task từ spec.md theo thứ tự subtask. Auto-execute liên tục, chỉ dừng ở hard-stop. Sinh report.html cumulative để review trực quan.
---

# Thực Hiện Implementation (Auto-Execute)

## Bước 1 — Đọc task
`git branch --show-current` → tìm `ai-code-kit/tasks/{branch-slug}/`:
- Không có → *"Chạy `/ai-plan` trước."* → Dừng
- Subtasks trống → *"Chạy `/ai-plan-edit` trước."* → Dừng
- `status` chưa `Approved` → *"Plan chưa được approve."* → Dừng
- Tất cả ✅ Done → *"Tất cả subtasks đã hoàn thành."* → Dừng

Đọc cả `## Research Findings` trong spec.md (nếu có).

## Bước 2 — Khởi tạo report.html (1 lần duy nhất)
Path: `ai-code-kit/tasks/{branch-slug}/report.html`. Nếu chưa tồn tại → tạo skeleton:
- HTML5, `lang="vi"`, UTF-8
- Inline CSS gọn (typography rõ, dark-friendly, responsive)
- highlight.js CDN + theme `github-dark` (cho `language-diff`)
- `<main id="report">` chứa `<header>` (task name, branch, ngày bắt đầu) và placeholder `<section id="subtasks">`

## Bước 3 — Loop subtask (AUTO, không hỏi giữa các ST)
Lặp cho đến khi hết ST `⬜ Pending` hoặc gặp hard-stop. Với mỗi ST:

1. Check Dependencies — ST cha phải Done. Chưa xong → skip, log "blocked by ST-X".
2. Báo: **"▶ ST-N: {tên}"** kèm danh sách `Files:` lấy từ spec.md của ST đó (báo trước khi sửa, không chờ tới report.html).
3. **Đọc files liên quan + grep usages** để hiểu impact (bắt buộc với symbol public).
4. **Implement**:
   - Minimal diff, đúng scope ST.
   - **Comment WHY** ở luồng phức tạp (multi-step business logic, workaround cho bug cụ thể, invariant ẩn, edge case không obvious). KHÔNG comment WHAT.
5. Chạy test command nếu project có config (`package.json scripts.test`, `Makefile`, `pytest.ini`…). Verify acceptance criteria.
6. **Append section vào report.html** (Bước 4).
7. **Update tracking.md**: row ST → `✅ Done | {date} | {ghi chú}`; `last_updated`; append Changelog `### {date} — ST-N: {tóm tắt}`.
8. Báo 1 dòng: **"✓ ST-N done"** → tiếp ST kế (KHÔNG chờ user).

## Bước 4 — Append vào report.html mỗi khi ST done
Insert `<section class="subtask" id="st-N">` ngay TRƯỚC `</main>`. Chứa:
- `<h2>ST-N: {tên}</h2>` + thẻ ngày
- **Summary**: 1-3 câu — đã làm gì + tại sao (WHY)
- **Acceptance**: `<ul>` với ✓/✗ từng criterion
- **Files changed**: `<details>` collapsible — list file (create/edit/delete) + diff (`<pre><code class="language-diff">`, escape `<>&`)
- **Impact analysis**: symbol public bị ảnh hưởng + danh sách callers (từ grep ở Bước 3.3)

Khi tất cả ST xong → insert `<section class="overview">` ở đầu `<main>` (sau `<header>`): tổng số ST, danh sách file thay đổi cộng dồn, key decisions.

## Bước 5 — Hard-Stops (DỪNG + chờ user)
Chỉ dừng auto-execute khi gặp các tình huống sau. Báo rõ, chờ "ok"/feedback:

| Tình huống | Hành động |
|---|---|
| Cần `npm/pnpm/yarn/composer/pip install/uninstall/upgrade` | In command + lý do, chờ confirm |
| Migration / seed / drop / truncate / alter DB | In SQL/command, chờ confirm |
| `rm -rf`, `git reset --hard`, force push, xóa branch | In command, chờ confirm |
| Phát hiện cần sửa code ngoài scope ST | Ghi Changelog `Phát hiện: {X}`, hỏi: "thêm ST mới hay skip?" |
| Phát hiện bug ở ST khác đã ✅ Done | DỪNG. Không tự sửa ST đó (bất biến) — đề xuất chạy `/ai-plan-edit` để tạo ST mới tham chiếu |
| Intent thiếu thông tin để quyết định | Hỏi cụ thể, KHÔNG tự assume |
| Test fail / acceptance không pass sau implement | In log, hỏi: "debug tiếp / rollback / skip?" |

## Bước 6 — Kết thúc task
Sau ST cuối: `status: Done` trong tracking.md frontmatter, append overview vào report.html, báo:
*"✅ Hoàn thành {N} subtasks. Mở `ai-code-kit/tasks/{slug}/report.html` để review."*

## ⚖️ IRON LAWS
1. **HARD-STOP → DỪNG.** Không tự install/migrate/destructive op.
2. **NGOÀI SCOPE → DỪNG, BÁO, CHỜ.** Không tự mở rộng.
3. **KHÔNG SỬA `## Intent` trong spec.md** — kể cả thêm dấu chấm.
4. **MỖI ST DONE → BẮT BUỘC APPEND report.html + UPDATE tracking.md.** Không skip.
5. **COMMENT WHY ở luồng phức tạp.** Không comment WHAT.

## 🚩 Red Flags
| Claude tự nhủ | Phản biện đúng |
|---|---|
| "Install nhanh dep này cho gọn" | Hard-stop. Hỏi user. |
| "Migration nhỏ, chạy luôn" | Hard-stop. Hỏi user. |
| "Test fail nhẹ, vẫn tick Done" | Acceptance fail → DỪNG, không tick. |
| "Skip report.html cho ST đơn giản" | Mọi ST đều append. |
| "Tiện tay fix typo ngoài scope" | Note Changelog, KHÔNG fix. |
| "Bug nhỏ ở ST cũ, sửa luôn cho nhanh" | Hard-stop. ST Done là final — tạo ST mới qua `/ai-plan-edit`. |
| "Code rõ rồi, comment thừa" | Đúng cho WHAT. WHY phức tạp → BẮT BUỘC. |
| "Project không có test, skip im lặng" | Báo "cần manual test [list]". |
| "Grep callers tốn thời gian" | Impact analysis là bắt buộc cho report. |
| "User chắc đồng ý dep này, install luôn" | Im lặng ≠ ok. Hard-stop. |

## Gotchas
- ❌ Tạo report.html từ đầu mỗi ST → mất lịch sử. Check tồn tại, chỉ tạo skeleton 1 lần.
- ❌ Append section sau `</main>` → HTML invalid. Insert TRƯỚC `</main>`.
- ❌ Embed diff thô không escape `<`, `>`, `&` → vỡ HTML hoặc XSS-like render.
- ❌ Quên highlight.js CDN → diff không màu, khó đọc.
- ❌ Bỏ qua hard-stop vì "chắc user đồng ý" → vi phạm Iron Law #1.
- ❌ Comment ở mọi function (kể cả trivial) → noise. Chỉ WHY non-obvious.
- ❌ Đọc spec.md nhưng bỏ qua `## Research Findings` → mất context từ `/ai-research`.
- ❌ Báo cáo "Files đã thay đổi" thiếu file (chỉ liệt kê edit, quên create/delete).