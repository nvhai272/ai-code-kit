---
name: commit
description: Stage, commit và push code. Tạo commit message theo Conventional Commits. Dùng sau khi review approved.
---

# Smart Commit

## Bước 1 — Kiểm tra trạng thái
```bash
git status
git diff --name-only
```
Không có changes → *"Không có gì để commit."* → Dừng

## Bước 2 — Stage files
Hỏi: **"Stage tất cả hay chỉ một số file?"**
- Tất cả → `git add .`
- Một số → hỏi cụ thể

## Bước 3 — Tạo commit message
```bash
git diff --staged
```
Format Conventional Commits:
```
<type>(<scope>): <mô tả ngắn, imperative>

Co-Authored-By: Claude <noreply@anthropic.com>
```
Types: `feat` | `fix` | `refactor` | `test` | `docs` | `chore` | `perf`
- Detect type từ loại thay đổi
- Detect scope từ files/dirs changed
- Tiêu đề ≤ 72 ký tự

Hiển thị message đề xuất → hỏi xác nhận.

## Bước 4 — Commit
Chờ xác nhận ("ok", "làm đi"):
```bash
git commit -m "{message}"
```

## Bước 5 — Push
Hỏi: **"Push lên remote không?"**
- Đã có upstream → `git push`
- Chưa có → `git push --set-upstream origin {branch}`

## Bước 6 — Kết quả
Hiển thị: branch, commit hash, message, files changed.

**Quy tắc:**
- KHÔNG `git push --force`
- Luôn hỏi xác nhận trước commit và trước push
- Không tự stage file ngoài những gì user chỉ định
