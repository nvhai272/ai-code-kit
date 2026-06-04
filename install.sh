#!/usr/bin/env bash
# install.sh — ai-code-kit
# Cài skills + hooks vào ~/.claude/, merge hook config vào settings.json
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_SRC="$TOOLKIT_DIR/.claude/skills"
HOOKS_SRC="$TOOLKIT_DIR/.claude/hooks"
FRAGMENT="$TOOLKIT_DIR/.claude/settings-fragment.json"
SETTINGS="$CLAUDE_DIR/settings.json"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
fail() { echo -e "${RED}✗${NC} $*"; exit 1; }

echo ""
echo "ai-code-kit installer v$(cat "$TOOLKIT_DIR/VERSION")"
echo "──────────────────────────────"

# ── 1. Prereqs ────────────────────────────────────────────────────────────────
command -v jq >/dev/null 2>&1 || fail "jq không tìm thấy. Chạy: sudo apt install jq"
ok "jq found"

# ── 2. Backup skills hiện có ──────────────────────────────────────────────────
if [ -d "$CLAUDE_DIR/skills" ]; then
  BACKUP="$CLAUDE_DIR/skills.bak.$(date +%Y%m%d%H%M%S)"
  cp -r "$CLAUDE_DIR/skills" "$BACKUP"
  warn "Backup skills cũ → $BACKUP"
fi

# ── 2b. Xóa skills cũ (tên cũ trước khi đổi prefix) ──────────────────────────
LEGACY_SKILLS=(plan plan-edit plan-do review debug think research)
for legacy in "${LEGACY_SKILLS[@]}"; do
  legacy_dir="$CLAUDE_DIR/skills/$legacy"
  if [ -d "$legacy_dir" ]; then
    rm -rf "$legacy_dir"
    warn "Removed legacy skill: $legacy"
  fi
done

# ── 3. Copy skills ────────────────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/skills"
INSTALLED_SKILLS=()
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  cp -r "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
  INSTALLED_SKILLS+=("$skill_name")
done
ok "Skills đã cài: ${INSTALLED_SKILLS[*]}"

# ── 4. Copy & chmod hooks ─────────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/hooks"
for hook in "$HOOKS_SRC"/*.sh; do
  cp "$hook" "$CLAUDE_DIR/hooks/"
  chmod +x "$CLAUDE_DIR/hooks/$(basename "$hook")"
done
ok "Hooks đã cài: $(ls "$CLAUDE_DIR/hooks/"*.sh | xargs -I{} basename {} | tr '\n' ' ')"

# ── 5. Merge hook config vào settings.json ────────────────────────────────────
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

# Backup settings trước khi merge
cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"

# Deep merge: giữ nguyên tất cả keys cũ, thêm/override hooks
jq -s '
  .[0] as $orig |
  .[1] as $frag |
  $orig * $frag |
  if ($orig.hooks != null) then
    .hooks = (
      ($orig.hooks // {}) |
      to_entries +
      ($frag.hooks | to_entries) |
      group_by(.key) |
      map({ key: .[0].key, value: (map(.value) | add) }) |
      from_entries
    )
  else . end
' "$SETTINGS" "$FRAGMENT" > /tmp/ct_settings_merged.json

mv /tmp/ct_settings_merged.json "$SETTINGS"
ok "settings.json đã được cập nhật với hook config"

# ── 6. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────"
echo -e "${GREEN}Cài đặt hoàn tất!${NC}"
echo ""
echo "Skills có thể dùng ngay:"
for s in "${INSTALLED_SKILLS[@]}"; do
  echo "  /$s"
done
echo ""
echo "Hooks đang chạy tự động:"
echo "  privacy-block  — block đọc .env, *.pem, credentials"
echo "  safety-guard   — block lệnh nguy hiểm"
echo "  session-init   — inject task đang In Progress khi mở session"
echo ""
echo "Workflow gợi ý:"
echo "  /ai-research → /ai-plan → /ai-plan-edit → approve → /ai-plan-do"
echo ""
