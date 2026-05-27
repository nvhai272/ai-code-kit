---
name: review
description: Review code thay đổi trên branch hiện tại. Đánh giá chất lượng, rủi ro, đề xuất cải tiến. Dùng trước khi merge hoặc sau khi hoàn thành subtask.
---

# Code Review

## Bước 1 — Thu thập thông tin

```bash
git branch --show-current
git diff HEAD --stat
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo main)
git diff $BASE...HEAD --stat
```

**Auto-detect mode:**
- Nếu `git diff HEAD` có output → **Working tree mode**: review uncommitted changes
- Nếu không có uncommitted changes → **Branch mode**: review tất cả commits trên branch so với base branch (`$BASE`)

Đọc `ai-code-kit/tasks/{branch-slug}/spec.md` nếu có để hiểu scope và acceptance criteria.

## Bước 2 — Đọc code thay đổi

**Working tree mode** (có uncommitted changes):
```bash
git diff HEAD
```

**Branch mode** (không có uncommitted changes):
```bash
git diff $BASE...HEAD
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
- Chỉ Warning → "Khuyến khích fix, nhưng có thể proceed và commit."
- Pass → "Approved — có thể commit."

**Giới hạn:** Chỉ đọc và báo cáo — KHÔNG tự sửa code.

## Gotchas

- ❌ Phát hiện Critical → tự edit fix luôn → SAI: chỉ báo cáo, user quyết định
- ❌ Review chỉ đọc diff lines, không Read đầy đủ context file → miss bug do code xung quanh
- ❌ Báo "Approve" khi acceptance criteria trong `spec.md` chưa được verify từng cái
- ❌ Bỏ qua check `## Out of Scope` — nếu diff chạm code ngoài scope thì phải flag
- ❌ Chỉ check security pattern phổ biến (SQL injection, XSS) → miss logic bug, race condition, auth bypass
- ❌ Chấm "Quality X/5" chủ quan không có evidence → kết luận yếu, user không action được
- ❌ Branch mode dùng `git diff $BASE..HEAD` (two dots) thay vì `$BASE...HEAD` (three dots) → diff sai nếu base branch đã advance
