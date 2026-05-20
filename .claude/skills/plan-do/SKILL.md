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

**Quy tắc bất biến:**
- Xong 1 ST → dừng, chờ xác nhận
- Không tick khi chưa có xác nhận
- Không sửa `## Intent` trong spec.md
