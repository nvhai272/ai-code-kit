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

## Bước 2 — Phân tích trước khi plan
Dùng Glob/Grep để hiểu codebase. Trả lời 3 câu hỏi:
1. Giả định nào đang được dùng? Có thể sai ở đâu?
2. Thay đổi này ảnh hưởng đến module/file nào khác?
3. Edge cases nào cần handle?

## Bước 3 — Generate vào spec.md

**`### In Scope` — Subtasks:**
```
**ST-N: [Tên]**
- Files: [danh sách files]
- Acceptance: [ ] điều kiện rõ ràng
- Effort: ~X phút
```
Thứ tự: Schema/DB → Service/Logic → API/Routes → Tests → Docs.
Subtask đã `✅ Done` → KHÔNG xóa, KHÔNG thay đổi.

**`### Out of Scope`** — liệt kê những gì không làm.

**`## Risks & Mitigations`**
```
| Risk | Severity | Mitigation |
```

**`## Success Criteria`** — checklist measurable.

**`## Dependencies`** — external + internal blockers.

Đổi frontmatter `status: Draft` → `status: Approved` **chỉ sau khi user approve**.

## Bước 4 — Cập nhật tracking.md
Thêm row cho mỗi ST mới: `| ST-N | {tên} | ⬜ Pending | | |`
Append Changelog: `### {date} — Plan generated: {N} subtasks`

## Bước 5 — Hiển thị & chờ approve
```
Kế hoạch: {N} subtasks (ST-1 → ST-N)
Risks: {top 2}
→ Gõ "ok" để approve, hoặc feedback để điều chỉnh.
```
**CHỜ xác nhận — KHÔNG tự làm task.**
