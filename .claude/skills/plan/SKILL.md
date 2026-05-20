---
name: plan
description: Khởi tạo task mới cho branch hiện tại. Tạo spec.md + tracking.md trong .dw/tasks/. Dùng khi bắt đầu feature hoặc task mới.
---

# Khởi Tạo Task

## Bước 1 — Xác định branch & tên task
Chạy `git branch --show-current`. Dùng tên branch làm task slug: thay `/` → `-`.
Hỏi: **"Dùng `{branch-slug}` làm tên task không?"**

## Bước 2 — Kiểm tra đã tồn tại
- Có `.dw/tasks/{branch-slug}/` → Báo: *"Task đã tồn tại. Dùng `/plan-edit` để chỉnh hoặc `/plan-do` để tiếp tục."* → Dừng
- Chưa có → tạo thư mục `.dw/tasks/{branch-slug}/`

## Bước 3 — Tạo spec.md
```
.dw/tasks/{branch-slug}/spec.md
```
Nội dung:
```markdown
---
task_id: {branch-slug}
created: {YYYY-MM-DD}
status: Draft
depth: standard
---

# Spec: {branch-slug}

## Intent
<!-- Mô tả task ở đây, sau đó chạy /plan-edit -->

## Scope
### In Scope
### Out of Scope

## Risks & Mitigations
## Success Criteria
## Dependencies
## Research Findings
```

## Bước 4 — Tạo tracking.md
```
.dw/tasks/{branch-slug}/tracking.md
```
Nội dung:
```markdown
---
task_id: {branch-slug}
started: {YYYY-MM-DD}
last_updated: {YYYY-MM-DD}
status: Not Started
---

# Tracking: {branch-slug}

## Subtask Progress
| # | Subtask | Status | Date | Notes |
|---|---------|--------|------|-------|

## Changelog

## Handoff Notes
```

## Bước 5 — Hướng dẫn tiếp theo
```
✅ Tạo xong:
  .dw/tasks/{branch-slug}/spec.md
  .dw/tasks/{branch-slug}/tracking.md

→ Mở spec.md, nhập mô tả vào ## Intent
→ Chạy /plan-edit để generate subtasks
```

**Quy tắc:** Không sửa file nào khác ngoài 2 files vừa tạo.
