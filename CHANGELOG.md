# Changelog

## [1.1.0] — 2026-05-20

### Removed
- Skill `commit` — dùng git commit trực tiếp hoặc qua Claude Code built-in
- Skill `handoff` — không còn cần thiết với session-init hook

### Changed
- Đổi tên thư mục task từ `.dw/tasks/` → `ai-code-kit/tasks/`
- Cập nhật tất cả tài liệu và scripts liên quan

## [1.0.0] — 2026-05-20

### Added
- 9 skills: plan, plan-edit, plan-do, review, commit, debug, think, handoff, research
- 3 hooks: privacy-block, safety-guard, session-init
- install.sh / uninstall.sh