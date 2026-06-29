---
name: ai-research
description: Khảo sát codebase trước khi lập kế hoạch. Tìm patterns, dependencies, và ảnh hưởng của thay đổi. Dùng trước /ai-plan-edit khi task phức tạp.
argument-hint: "[task-name hoặc mô tả ngắn về thay đổi]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(grep *)
  - Bash(git log *)
  - Bash(git diff *)
  - Bash(git blame *)
  - Bash(git show *)
  - Bash(ls *)
  - Bash(wc *)
---

# Khảo Sát Codebase

Task: **$ARGUMENTS**

## Bước 1 — Đọc task context
Tìm `ai-code-kit/tasks/{slug}/spec.md` nếu đã có. Đọc `## Intent` để hiểu mục tiêu.

## Bước 2 — Scan codebase

**Tìm entry points và patterns liên quan:**
```bash
# Tìm files theo tên/pattern
grep -r "{keyword}" --include="*.{ext}" -l
# Git history của khu vực liên quan
git log --oneline --follow -- {file/dir}
# Ai đã thay đổi file này gần đây
git blame {file} | tail -20
```

**Xác định:**
- Files cần thay đổi (trực tiếp)
- Files bị ảnh hưởng (gián tiếp — import, dependency, caller)
- Patterns/conventions đang dùng trong codebase
- Giới hạn kỹ thuật cần biết trước

## Bước 3 — Phân tích impact

**Dependency graph (nếu cần):**
```bash
grep -r "import.*{module}" --include="*.{ext}" -l
grep -r "require.*{module}" --include="*.{ext}" -l
```

Liệt kê:
- **Directly changed**: files chắc chắn cần sửa
- **Likely affected**: files có thể cần update
- **Watch out**: files dễ break nếu thay đổi không cẩn thận

## Bước 4 — Ghi findings vào spec.md

Thêm vào section `## Research Findings`:

```markdown
## Research Findings
*{date}*

**Files sẽ thay đổi:**
- `path/to/file` — lý do

**Files bị ảnh hưởng:**
- `path/to/file` — cần verify sau khi thay đổi

**Patterns codebase đang dùng:**
- [convention quan trọng cần follow]

**Cạm bẫy cần tránh:**
- [vấn đề tiềm ẩn phát hiện được]

**Câu hỏi còn mở:**
- [điều chưa rõ cần hỏi trước khi plan]
```

## Bước 5 — Tóm tắt
Báo cáo ngắn: scope thật sự là gì, rủi ro chính, đề xuất tiếp theo.
→ *"Chạy `/ai-plan-edit` để lập kế hoạch dựa trên research này."*

## Gotchas

- ❌ Grep quá hẹp (1 thư mục) thay vì toàn dự án → bỏ sót callers/dependencies ở module khác
- ❌ Ghi findings không phân biệt "directly changed" vs "likely affected" → plan sau thiếu chính xác
- ❌ Sửa code trong lúc research → skill này chỉ đọc + ghi `## Research Findings`
- ❌ Bỏ qua `git log`/`git blame` → mất context vì sao code hiện tại như vậy
