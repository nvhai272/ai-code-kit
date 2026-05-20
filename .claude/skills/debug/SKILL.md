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

## Phase 2 — HYPOTHESIZE: Đặt giả thuyết

Liệt kê **top 3 nguyên nhân có thể** theo thứ tự khả năng cao nhất:
1. **[Hypothesis A]** — Evidence ủng hộ: ... | Cách kiểm chứng: ...
2. **[Hypothesis B]** — Evidence ủng hộ: ... | Cách kiểm chứng: ...
3. **[Hypothesis C]** — Evidence ủng hộ: ... | Cách kiểm chứng: ...

Bắt đầu với hypothesis khả năng cao nhất.

## Phase 3 — FIX: Sửa và verify

**Trước khi sửa:**
- Đọc toàn bộ file liên quan (không chỉ dòng lỗi)
- Xác nhận root cause, không chỉ symptom
- Thông báo files sẽ thay đổi → chờ xác nhận

**Sau khi sửa:**
- Verify fix giải quyết đúng root cause
- Kiểm tra không có regression (grep usages, chạy test nếu có)
- Nếu hypothesis sai → quay lại Phase 2 với hypothesis tiếp theo

**Output tóm tắt:**
```
Root cause: [nguyên nhân thật sự]
Fix: [thay đổi đã làm]
Verified: [cách đã kiểm tra]
Prevention: [cách tránh lần sau — nếu có]
```

**Quy tắc:** Không sửa nhiều thứ cùng lúc — 1 hypothesis, 1 fix, 1 verify.
