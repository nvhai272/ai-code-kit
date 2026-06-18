---
name: ai-plan
description: Khởi tạo task mới cho branch hiện tại. Tạo spec.md + tracking.md trong ai-code-kit/tasks/. Dùng khi bắt đầu feature hoặc task mới.
allowed-tools:
  - Glob
  - Write
  - Bash(git branch --show-current)
---

# Khởi Tạo Task

## Bước 1 — Xác định branch & tên task
Chạy `git branch --show-current`. Dùng tên branch làm task slug: thay `/` → `-`.
Hỏi: **"Dùng `{branch-slug}` làm tên task không?"**

## Bước 2 — Kiểm tra đã tồn tại
- Có `ai-code-kit/tasks/{branch-slug}/` → Báo: *"Task đã tồn tại. Dùng `/ai-plan-edit` để chỉnh hoặc `/ai-plan-do` để tiếp tục."* → Dừng
- Chưa có → tạo thư mục `ai-code-kit/tasks/{branch-slug}/`

## Bước 3 — Tạo spec.md
```
ai-code-kit/tasks/{branch-slug}/spec.md
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
<!-- Mô tả task ở đây, sau đó chạy /ai-plan-edit -->

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
ai-code-kit/tasks/{branch-slug}/tracking.md
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
  ai-code-kit/tasks/{branch-slug}/spec.md
  ai-code-kit/tasks/{branch-slug}/tracking.md

→ Mở spec.md, nhập mô tả vào ## Intent
→ Chạy /ai-plan-edit để generate subtasks
```

**Quy tắc:** Không sửa file nào khác ngoài 2 files vừa tạo.

## Gotchas

- ❌ Tạo task khi chưa checkout đúng branch → task slug lệch với branch thực tế
- ❌ Ghi đè `spec.md`/`tracking.md` đã tồn tại → mất Intent + lịch sử (phải check tồn tại ở Bước 2)
- ❌ Tự điền nội dung vào `## Intent` thay vì để trống cho user → vi phạm vùng cấm
- ❌ Tạo thêm file/thư mục ngoài 2 file spec.md + tracking.md
