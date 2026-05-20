---
name: review
description: Review code thay đổi trên branch hiện tại. Đánh giá chất lượng, rủi ro, đề xuất cải tiến. Dùng trước khi merge hoặc sau khi hoàn thành subtask.
---

# Code Review

## Bước 1 — Thu thập thông tin
```bash
git branch --show-current
git diff main..HEAD --name-only
git diff main..HEAD --stat
```
Đọc `ai-code-kit/tasks/{branch-slug}/spec.md` nếu có để hiểu scope và acceptance criteria.

## Bước 2 — Đọc code thay đổi
```bash
git diff main..HEAD
```
Dùng Read để đọc đầy đủ context từng file (không chỉ diff).
Dùng Grep để tìm usages, kiểm tra breaking changes.

## Bước 3 — Review theo tiêu chí

**🔴 CRITICAL — Phải sửa trước khi merge**
- Logic sai, business behavior không đúng
- Security vulnerabilities (injection, auth bypass, data exposure)
- Nguy cơ mất data
- Breaking API contract không có migration
- Missing error handling quan trọng

**🟡 WARNING — Nên sửa**
- Performance (N+1 queries, missing index)
- Error handling thiếu
- Code smells giảm maintainability
- Test coverage chưa đủ

**🔵 SUGGESTION — Cân nhắc**
- Refactoring nhỏ, DRY improvements
- Naming rõ hơn, style nhất quán

**Checklist:**
```
[ ] Correctness: Logic đúng? Edge cases?
[ ] Security: Input validation? Auth check?
[ ] Performance: N+1? Unnecessary calls?
[ ] Error handling: Caught? Logged đủ context?
[ ] Conventions: Naming? Code style?
[ ] Scope: Có vượt ngoài plan không?
```

## Bước 4 — Output
```markdown
# Review: {branch}

## Tóm tắt
{Mô tả ngắn những gì changed}

## Đánh giá
- Quality: X/5 | Security: ✅/⚠️/🚫 | Scope: ✅/⚠️

## 🔴 Critical
- **[file:line]** — {vấn đề} → Fix: {hướng dẫn}

## 🟡 Warnings
- **[file:line]** — {mô tả}

## 🔵 Suggestions
- **[file:line]** — {gợi ý}

## ✅ Điểm tốt
- {ghi nhận}

**Kết luận:** Approve / Request Changes / Needs Discussion
```

## Sau review
- Critical → "Cần fix trước khi merge. Sau khi fix chạy lại `/review`."
- Chỉ Warning → "Khuyến khích fix, nhưng có thể proceed với `/commit`."
- Pass → "Approved — chạy `/commit`."

**Giới hạn:** Chỉ đọc và báo cáo — KHÔNG tự sửa code.
