# Changelog

## [1.2.1] — 2026-05-22

### Added
- `/plan-do`: Iron Laws + Red Flags table (chống Claude drift behavior)
- `/plan-do`, `/debug`, `/review`: section Gotchas (best practice từ Anthropic — chống lỗi phổ biến)

## [1.2.0] — 2026-05-20

### Changed
- `/debug`: Thêm bước trace read/write path cho bug "dữ liệu sai"
- `/debug`: Grep toàn dự án (`.`) thay vì hardcode `app/` — phù hợp mọi stack
- `/debug`: Impact analysis bắt buộc grep tất cả callers trước khi fix
- `/debug`: Regression check tường minh — verify callers hoặc thông báo danh sách cần test thủ công nếu không có test
- `/review`: Auto-detect mode — tự nhận biết working tree changes vs branch changes
- `/review`: Base branch detect động từ `origin/HEAD` thay vì hardcode `main`

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