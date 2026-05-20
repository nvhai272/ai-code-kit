---
name: debug
description: Debug có hệ thống theo quy trình Observe → Hypothesize → Fix. Dùng khi gặp lỗi, test fail, hoặc behavior bất thường.
argument-hint: "[mô tả vấn đề]"
---

# Debug Có Hệ Thống

Vấn đề: **$ARGUMENTS**

## Phase 1 — OBSERVE: Thu thập thông tin

**Symptoms:**
- Error message đầy đủ? (stack trace, log)
- Reproduction steps? Xảy ra lần đầu khi nào?
- Tần suất: always / flaky / one-time?
- Môi trường: dev / staging / prod?

**Evidence:**
```bash
git log --oneline -10        # thay đổi gần đây
git diff HEAD~3              # diff 3 commits gần nhất
```
Đọc log, đọc file liên quan, grep error message trong codebase.

**Với bug "dữ liệu sai" — bắt buộc trace cả 2 chiều:**
- **Read path**: ai đọc dữ liệu và hiển thị ra? (query, render, format)
- **Write path**: ai ghi dữ liệu vào? (create, update, import, seed)
- Không loại trừ chiều nào trước khi có bằng chứng cụ thể.

**Sau khi tìm ra pattern gây bug — bắt buộc grep toàn codebase:**
```bash
grep -rn "<pattern>" .   # tìm tất cả nơi dùng cùng pattern hoặc function liên quan trong toàn dự án
```
Mục tiêu: phát hiện các file khác mắc lỗi tương tự trong cùng lần debug.

## Phase 2 — HYPOTHESIZE: Đặt giả thuyết

Liệt kê **top 3 nguyên nhân có thể** theo thứ tự khả năng cao nhất:
1. **[Hypothesis A]** — Evidence ủng hộ: ... | Cách kiểm chứng: ...
2. **[Hypothesis B]** — Evidence ủng hộ: ... | Cách kiểm chứng: ...
3. **[Hypothesis C]** — Evidence ủng hộ: ... | Cách kiểm chứng: ...

Bắt đầu với hypothesis khả năng cao nhất.

**Với bug "dữ liệu sai" — hypothesis phải cover đủ 2 tầng:**
- Tầng đọc: dữ liệu đúng trong DB nhưng bị query/transform/hiển thị sai?
- Tầng ghi: dữ liệu đã bị lưu sai vào DB từ trước?

## Phase 3 — FIX: Sửa và verify

**Trước khi sửa — impact analysis (bắt buộc):**
- Đọc toàn bộ file liên quan (không chỉ dòng lỗi)
- Xác nhận root cause, không chỉ symptom
- Grep tất cả caller của function/method sẽ thay đổi:
  ```bash
  grep -rn "tên_function" .
  ```
- Với mỗi caller: xác định fix có thay đổi behavior của caller đó không
- Nếu có caller bị ảnh hưởng ngoài ý muốn → điều chỉnh approach (thêm param optional, tạo method mới, v.v.)
- Thông báo files sẽ thay đổi và phạm vi ảnh hưởng → chờ xác nhận

**Sau khi sửa — regression check (bắt buộc):**
- Verify fix giải quyết đúng root cause
- Với mỗi caller đã tìm được ở impact analysis: xác nhận behavior không thay đổi ngoài ý muốn
- Nếu project có test: chạy test bao phủ các caller đó (không chỉ test file vừa sửa)
- Nếu không có test: thông báo rõ với user:
  > "Các chức năng sau dùng code vừa sửa, cần kiểm tra thủ công: [danh sách caller]"
- Nếu hypothesis sai → quay lại Phase 2 với hypothesis tiếp theo

**Output tóm tắt:**
```
Root cause: [nguyên nhân thật sự]
Fix: [thay đổi đã làm]
Verified: [cách đã kiểm tra]
Prevention: [cách tránh lần sau — nếu có]
```

**Quy tắc:** Không sửa nhiều thứ cùng lúc — 1 hypothesis, 1 fix, 1 verify.
