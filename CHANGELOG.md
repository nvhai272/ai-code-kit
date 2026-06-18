# Changelog

## [1.6.2] — 2026-06-19

### Fixed
- `safety-guard.sh`: Pattern 3 (`DELETE`/`UPDATE` thiếu `WHERE`) và Pattern 4 (DROP statement) block nhầm khi chữ đó chỉ là text thường (ví dụ commit message mô tả bug) vì hook chỉ grep chuỗi thô, không phân biệt text với SQL thật. Thêm guard: 2 pattern này chỉ check khi command có gọi 1 DB client thật (`psql`/`mysql`/`mariadb`/`sqlite3`/`mongosh`/`mongo`/`redis-cli`/`sqlcmd`/`osql`).

## [1.6.1] — 2026-06-19

### Fixed
- `safety-guard.sh`: `DROP TABLE`/`DROP DATABASE`/`DROP SCHEMA` chỉ cảnh báo (`exit 0`, vẫn cho chạy) trong khi `DELETE`/`UPDATE` thiếu `WHERE` đã bị block (`exit 2`) — không nhất quán mức rủi ro. Đổi DROP statement sang block cứng.
- `ai-plan`, `ai-plan-edit`: thiếu `allowed-tools` trong frontmatter dù skill tự khai chỉ ghi `spec.md`/`tracking.md` — thêm `allowed-tools` giới hạn đúng phạm vi đã khai báo.
- `ai-plan-do`: danh sách file bị ảnh hưởng của 1 ST chỉ xuất hiện trong `report.html` sau khi đã implement xong — giờ báo kèm khi announce `▶ ST-N`, trước khi sửa code.
- `CLAUDE.md`: bổ sung cảnh báo khi làm việc trong chính thư mục `ai-code-kit/`, skill scoped tại đây ưu tiên hơn bản global nên có thể đang chạy bản source chưa `install.sh`.

## [1.6.0] — 2026-06-17

### Added
- `ai-plan-edit`: hỗ trợ **reopen** task đã `Done` khi có feedback/bug mới — reset `tracking.md` về `In Progress` và `spec.md` về `Draft`, chờ approve lại. Bug ở 1 ST cụ thể đã `✅ Done` → tạo **ST mới tham chiếu** (`Fix bug ở ST-X`), không sửa/xóa ST cũ (giữ bất biến).
- `ai-plan-do`: thêm hard-stop "phát hiện bug ở ST khác đã ✅ Done" — dừng, đề xuất chạy `/ai-plan-edit` thay vì tự sửa.
- `ai-debug`: sau khi fix xong, nếu branch hiện tại có active task (`tracking.md` `status: In Progress`) → tự append Changelog `Bug fix: {root cause}`. Không có active task → bỏ qua, không tạo file mới.

### Fixed
- `install.sh`: `cp -r "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"` không overwrite khi đích đã tồn tại — nest thành `<skill>/<skill>/SKILL.md`, khiến `SKILL.md` top-level (file Claude Code thực sự đọc) **không bao giờ được cập nhật** ở các lần install lại. Bug tồn tại từ trước, ảnh hưởng mọi skill. Thêm `rm -rf` trước `cp -r` để đảm bảo overwrite đúng.

## [1.5.0] — 2026-06-11

### Changed
- `ai-plan-do`: chuyển sang **auto-execute** — tự chạy liên tục qua các subtask, không còn dừng chờ "ok" sau mỗi ST. Chỉ dừng khi gặp **hard-stop**: install/gỡ dependency, migration/seed/drop DB, destructive ops (`rm -rf`, `git reset --hard`, force push), phát hiện ngoài scope, Intent thiếu thông tin, test/acceptance fail.
- `ai-plan-do`: thêm yêu cầu **comment WHY** ở luồng phức tạp (business logic nhiều bước, workaround, invariant ẩn). Không comment WHAT.
- `ai-plan-do`: Iron Laws + Red Flags cập nhật cho flow auto-execute (bỏ "stop-per-ST", thêm "hard-stop nguyên tắc").

### Added
- `ai-plan-do`: sinh `ai-code-kit/tasks/{branch-slug}/report.html` **cumulative** — mỗi ST done append 1 section gồm Summary + Acceptance, Files changed kèm syntax-highlighted diff (highlight.js CDN), Impact analysis (symbols + callers). Khi task xong có overview tổng kết. Mở bằng browser để review trực quan.

## [1.4.1] — 2026-06-08

### Fixed
- `session-init.sh`: reference chết `/plan-do hoặc /handoff` → `/ai-plan-do`
- `session-init.sh`: regex parse subtask mất tên (chỉ lấy `ST-N`, mất `: tên subtask`) → dùng awk parse cột table
- `safety-guard.sh`: bypass force push bằng `-f` short flag và `+refspec` syntax → match đầy đủ
- `safety-guard.sh`: parse JSON command bằng regex bị cắt khi có escaped quote → đổi sang `jq`
- `privacy-block.sh`: thiếu pattern SSH keys (`id_rsa`, `id_ed25519`...), `.npmrc`, `.netrc`, `.pgpass`, `.pypirc`
- `install.sh`: không xóa orphan `ai-review`/`ai-think` khi upgrade từ v1.3.0 → thêm vào `LEGACY_SKILLS`
- `install.sh`: jq merge dupe hooks khi chạy lại → pre-clean ai-code-kit hooks trước khi merge
- `uninstall.sh`: không dọn session markers `/tmp/ct-session-*`

## [1.4.0] — 2026-06-04

### Removed
- Skill `ai-review` — dùng `/code-review` built-in hoặc review thủ công
- Skill `ai-think` — gộp tư duy phản biện vào flow thường ngày

### Changed
- `ai-plan-do`: bỏ gợi ý `/ai-review` sau khi xong subtask
- `install.sh` / `uninstall.sh`: cập nhật danh sách skills còn lại
- README, CLAUDE.md: bỏ tham chiếu 2 skill đã xóa (còn 5 skills)

## [1.3.0] — 2026-05-27

### Changed
- Tất cả skills đổi tên sang prefix `ai-`: `ai-plan`, `ai-plan-edit`, `ai-plan-do`, `ai-review`, `ai-debug`, `ai-think`, `ai-research`
- `install.sh`: tự xóa skill cũ (tên cũ không có prefix) khi cài lại
- Cross-references giữa các skills cập nhật theo tên mới

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