# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Bản chất repo

Đây là **source** cho `~/.claude/skills/*` và `~/.claude/hooks/*` của user — không phải project code thường. Sửa file trong repo này **không có hiệu lực** cho đến khi chạy lại `install.sh`. Repo deploy ra `~/.claude/` của user, các project khác trên máy đều dùng skills/hooks này (project có thể override bằng `.claude/skills/<name>/` riêng).

⚠️ **Ngoại lệ:** khi làm việc *trong chính thư mục `ai-code-kit/`*, skill scoped tại đây (`.claude/skills/<name>/`) được ưu tiên hơn bản global — nghĩa là bạn đang chạy bản **source chưa install**, có thể khác bản đã deploy ở các project khác. Sau khi sửa SKILL.md/hook, chạy `install.sh` ngay để tránh nhầm "đang test bản nào".

## Commands

```bash
bash install.sh      # Deploy skills + hooks vào ~/.claude/, merge hooks vào settings.json
bash uninstall.sh    # Gỡ skills + hooks, xóa hook config khỏi settings.json
```

Không có build, lint, test — đây là shell + markdown.

**Yêu cầu:** `jq` (cho merge `settings.json`).

## Kiến trúc

```
ai-code-kit/
├── .claude/
│   ├── skills/<name>/SKILL.md        # 5 skills (frontmatter name+description+md)
│   ├── hooks/*.sh                    # 3 hooks (privacy-block, safety-guard, session-init)
│   └── settings-fragment.json        # Hook config — install.sh jq-deep-merge vào ~/.claude/settings.json
├── install.sh   uninstall.sh
├── VERSION                            # install.sh đọc runtime để hiển thị
├── README.md   CHANGELOG.md
```

**Skills (5):** `ai-plan` → `ai-plan-edit` → `ai-plan-do`, kèm `ai-research` / `ai-debug`. Task data sống tại `ai-code-kit/tasks/{branch-slug}/{spec.md,tracking.md,report.html}` trong project tiêu thụ, không phải repo này.

**Hooks (3):**
- `privacy-block` (PreToolUse:Read) — chặn đọc `.env`, `*.pem`, `credentials/*`
- `safety-guard` (PreToolUse:Bash) — chặn `rm -rf /|*|.`, force push lên main, SQL không WHERE
- `session-init` (UserPromptSubmit) — scan `ai-code-kit/tasks/*/tracking.md` cho `status: In Progress`, inject 1 lần/session

## Invariants khi sửa

| Thay đổi | Phải cập nhật |
|---|---|
| Thêm/xóa skill | `TOOLKIT_SKILLS` trong `uninstall.sh` |
| Thêm/xóa hook | `TOOLKIT_HOOKS` trong `uninstall.sh` + entry trong `.claude/settings-fragment.json` + regex trong jq filter của `uninstall.sh` |
| Bump version | `VERSION` + footer `README.md` (`*ai-code-kit vX.Y.Z*`) + entry mới đầu `CHANGELOG.md` |
| Sửa SKILL.md | Chỉ có hiệu lực sau `bash install.sh` (deploy ra `~/.claude/skills/`) |

## Skill design conventions (đã áp dụng cho repo này)

- SKILL.md ngắn (< 100 dòng) — best practice Anthropic là < 500
- Frontmatter có `name` + `description`; thêm `argument-hint` / `allowed-tools` khi phù hợp
- **Iron Laws + Red Flags table** ở cuối skill rigid (`ai-plan-do`) — pattern chống Claude drift
- **Gotchas section** ở cuối mỗi skill — lỗi phổ biến + cách tránh (best practice Anthropic)
- Toàn bộ user-facing text bằng **tiếng Việt** — giữ convention khi sửa hoặc thêm skill mới

## Quy ước task workflow (dùng skills này tạo ra)

- `spec.md` có frontmatter `status: Draft|Approved`; `tracking.md` có `status: Not Started|In Progress|Done`
- `## Intent` trong spec.md là **vùng cấm sửa** — chỉ user viết, AI không bao giờ chỉnh kể cả thêm dấu
- Subtask đã `✅ Done` không bao giờ bị xóa hay đổi nội dung
- `report.html` chỉ tạo skeleton 1 lần; các ST sau chỉ **append** section — không tạo lại từ đầu (mất lịch sử)
- Task `Done` + feedback/bug mới → **reopen** qua `/ai-plan-edit`: `tracking.md` về `In Progress`, `spec.md` về `Draft`, chờ approve lại
- Bug ở 1 ST đã `✅ Done` → tạo ST mới tham chiếu (`Fix bug ở ST-X`), không sửa/xóa ST cũ
- `/ai-debug` tự append Changelog vào `tracking.md` nếu branch hiện tại có active task (`status: In Progress`)
- `session-init` detect task active bằng grep `^status: In Progress` trong tracking.md frontmatter