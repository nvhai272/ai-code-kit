---
name: handoff
description: Tạo tài liệu bàn giao session. Ghi vào tracking.md để session tiếp theo tiếp tục không cần hỏi lại. Dùng cuối session hoặc khi chuyển task.
argument-hint: "[task-name — mặc định dùng branch hiện tại]"
---

# Session Handoff

## Bước 1 — Xác định task
- Nếu có `$ARGUMENTS` → dùng làm task slug
- Nếu không → `git branch --show-current` → slug

Tìm `ai-code-kit/tasks/{slug}/tracking.md`:
- Không có → *"Không tìm thấy task. Chạy `/plan` trước."* → Dừng

## Bước 2 — Thu thập trạng thái hiện tại
```bash
git status
git log --oneline -5
```
Đọc `spec.md` (Intent, Subtasks) + `tracking.md` (Subtask Progress, Changelog).

## Bước 3 — Ghi vào tracking.md

Thay thế (hoặc append vào) section `## Handoff Notes`:

```markdown
## Handoff Notes

### {YYYY-MM-DD HH:MM} — Session End

**Đã làm trong session này:**
- [việc đã hoàn thành]

**Trạng thái hiện tại:**
- Subtask đang làm: ST-N — {tên} ({status})
- Files đang dở: [danh sách nếu có]
- Uncommitted changes: {có/không — tóm tắt}

**Bước tiếp theo:**
- [action cụ thể đầu tiên cần làm khi quay lại]

**Context cần biết:**
- [quyết định đã đưa ra, lý do, cạm bẫy đã gặp]
```

Cập nhật frontmatter `last_updated`.

## Bước 4 — Tóm tắt cho user
```
✅ Handoff saved → ai-code-kit/tasks/{slug}/tracking.md

Khi quay lại: chạy /plan-do để tiếp tục từ {ST-N}
```
