---
name: ai-plan-edit
description: Đọc Intent trong spec.md và generate Subtasks, Risks, Success Criteria. Dùng sau khi nhập mô tả vào ## Intent, hoặc khi cần cập nhật plan.
---

# Lập Kế Hoạch Implementation

## Bước 1 — Đọc task
`git branch --show-current` → tìm `ai-code-kit/tasks/{branch-slug}/spec.md` + `tracking.md`.
- Không có file → *"Chạy `/ai-plan` trước."* → Dừng
- `## Intent` trống → *"Nhập mô tả vào ## Intent trong spec.md trước."* → Dừng
- **`## Intent` là vùng cấm — chỉ đọc, không bao giờ sửa.**

## Bước 2 — Reopen nếu task đã Done nhưng có feedback mới
- `tracking.md` đang `status: Done` và user đưa feedback mới (bug, thiếu sót, yêu cầu thêm) → đây là **reopen**, không phải lỗi:
  - `tracking.md`: `status: Done` → `In Progress`
  - `spec.md`: `status: Approved` → `Draft` (chờ approve lại ở Bước 6)
  - Append Changelog tracking.md: `### {date} — Reopened: {tóm tắt feedback}`
- Feedback mô tả **bug ở 1 ST cụ thể đã ✅ Done** → KHÔNG sửa/xóa ST đó (vẫn bất biến). Tạo **ST mới** tham chiếu, xem Bước 4.

## Bước 3 — Phân tích trước khi plan
Dùng Glob/Grep để hiểu codebase. Trả lời 3 câu hỏi:
1. Giả định nào đang được dùng? Có thể sai ở đâu?
2. Thay đổi này ảnh hưởng đến module/file nào khác?
3. Edge cases nào cần handle?

## Bước 4 — Generate vào spec.md

**`### In Scope` — Subtasks:**
```
**ST-N: [Tên]**
- Files: [danh sách files]
- Acceptance: [ ] điều kiện rõ ràng
- Effort: ~X phút
```
Thứ tự: Schema/DB → Service/Logic → API/Routes → Tests → Docs.
Subtask đã `✅ Done` → KHÔNG xóa, KHÔNG thay đổi.

Bug ở ST đã Done (theo Bước 2) → thêm ST mới dạng:
```
**ST-N: Fix bug ở ST-X — [tóm tắt bug]**
- Files: [danh sách files]
- Acceptance: [ ] điều kiện rõ ràng
- Effort: ~X phút
```

**`### Out of Scope`** — liệt kê những gì không làm.

**`## Risks & Mitigations`**
```
| Risk | Severity | Mitigation |
```

**`## Success Criteria`** — checklist measurable.

**`## Dependencies`** — external + internal blockers.

Đổi frontmatter `status: Draft` → `status: Approved` **chỉ sau khi user approve**.

## Bước 5 — Cập nhật tracking.md
Thêm row cho mỗi ST mới: `| ST-N | {tên} | ⬜ Pending | | |`
Append Changelog: `### {date} — Plan generated: {N} subtasks` (hoặc đã append ở Bước 2 nếu là reopen).

## Bước 6 — Hiển thị & chờ approve
```
Kế hoạch: {N} subtasks (ST-1 → ST-N)
Risks: {top 2}
→ Gõ "ok" để approve, hoặc feedback để điều chỉnh.
```
**CHỜ xác nhận — KHÔNG tự làm task.**

## Gotchas

- ❌ Sửa `## Intent` dù chỉ thêm dấu → vùng cấm, chỉ đọc
- ❌ Đổi `status` → `Approved` trước khi user gõ "ok"
- ❌ Xóa/đổi nội dung subtask đã `✅ Done` khi re-generate plan
- ❌ Sửa trực tiếp ST đã Done khi có bug → phải tạo ST mới tham chiếu (Bước 4), giữ ST cũ bất biến
- ❌ Reopen task Done nhưng quên đổi `spec.md` `status` về `Draft` → `/ai-plan-do` không biết cần re-approve
- ❌ Generate subtask thiếu `Files` + `Acceptance` cụ thể → plan mơ hồ, khó verify
- ❌ Bắt tay sửa code → skill này chỉ ghi `spec.md` + `tracking.md`
