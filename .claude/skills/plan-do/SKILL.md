---
name: plan-do
description: Thực hiện task từ spec.md theo thứ tự subtask. Dùng sau khi plan đã được approve.
---

# Thực Hiện Implementation

## Bước 1 — Đọc task
`git branch --show-current` → tìm `ai-code-kit/tasks/{branch-slug}/`:
- Không có → *"Chạy `/plan` trước."* → Dừng
- Subtasks trống → *"Chạy `/plan-edit` trước."* → Dừng
- `status` chưa `Approved` → *"Plan chưa được approve."* → Dừng
- Tất cả ✅ Done → *"Tất cả subtasks đã hoàn thành."* → Dừng

## Bước 2 — Chọn subtask
Tìm ST đầu tiên còn `⬜ Pending` theo thứ tự trong tracking.md.
Kiểm tra Dependencies — ST cha phải xong trước.
Thông báo: **"Bắt đầu {ST-N}: {tên}"**

## Bước 3 — Thực hiện
Trước khi code:
- Đọc toàn bộ files liên quan
- Grep tìm usages bị ảnh hưởng
- Liệt kê files sẽ thay đổi → chờ xác nhận

Nếu project có test command (package.json scripts, Makefile...) → chạy sau khi implement.
Chỉ sửa đúng scope subtask — không động code ngoài.

## Bước 4 — Báo cáo & chờ
```
## Hoàn Thành {ST-N}: {tên}
Files đã thay đổi: [danh sách]
Acceptance: [x] đã đạt / [ ] chưa check

→ /review để review code, hoặc "ok" để tiếp tục.
```
**KHÔNG tự làm subtask tiếp theo khi chưa có xác nhận.**

## Bước 5 — Cập nhật sau khi user xác nhận
Khi user gõ "ok" / "tiếp" / "được":

**tracking.md:**
- Row subtask: `✅ Done | {date} | {ghi chú ngắn}`
- Frontmatter: `last_updated`, `status` (In Progress / Done nếu hết ST)
- Changelog: `### {date} — ST-N: {tóm tắt thay đổi}`

Thông báo subtask tiếp theo (nếu còn).

## Khi phát hiện vấn đề ngoài scope
1. DỪNG ngay
2. Ghi vào Changelog: `Phát Hiện: {vấn đề}`
3. Báo user, chờ quyết định — không tự mở rộng scope

## ⚖️ IRON LAWS — KHÔNG BAO GIỜ VI PHẠM

1. **XONG 1 ST → DỪNG. CHỜ USER GÕ "ok" / "tiếp" / "được".**
2. **KHÔNG TÍCH `✅ Done` TRƯỚC KHI USER XÁC NHẬN.**
3. **KHÔNG SỬA `## Intent` TRONG spec.md — kể cả thêm dấu chấm.**
4. **PHÁT HIỆN NGOÀI SCOPE → DỪNG, BÁO, CHỜ — KHÔNG TỰ MỞ RỘNG.**

## 🚩 Red Flags — Lý lẽ Claude hay dùng để phá luật

| Claude tự nhủ | Phản biện đúng |
|---|---|
| "User im lặng = ngầm đồng ý, làm ST tiếp" | Im lặng ≠ ok. Hỏi rõ. |
| "Acceptance có vẻ pass, tick Done cho gọn" | Chờ user verify. |
| "Intent thiếu 1 chi tiết, bổ sung 1 dòng" | Intent là vùng cấm. Báo user. |
| "Tiện tay fix typo / dead code ngoài scope" | Note vào Changelog, KHÔNG fix. |
| "ST này nhỏ, gộp ST tiếp cho gọn" | 1 ST = 1 stop. |
| "Project không có test, skip phần test" | Báo "cần manual test [list]" — không skip âm thầm. |
| "Grep callers tốn thời gian, skip vì thay đổi nhỏ" | Không skip. Impact analysis là bắt buộc. |

## Gotchas

- ❌ Chạy test command mà không kiểm tra project có config test không (`package.json scripts.test`, `Makefile`, `pytest.ini`...) → có thể chạy nhầm command sai
- ❌ Khi user feedback giữa chừng "à thêm cái X", coi đó là ST mới → KHÔNG: hỏi user "thêm vào ST hiện tại hay tạo ST mới?"
- ❌ Quên cập nhật `last_updated` trong frontmatter tracking.md sau khi tick Done
- ❌ Báo cáo "Files đã thay đổi" thiếu file (chỉ liệt kê file edit, quên file create/delete)
- ❌ Đọc spec.md nhưng bỏ qua `## Research Findings` → mất context quan trọng từ `/research`
