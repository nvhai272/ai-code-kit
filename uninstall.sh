#!/usr/bin/env bash
# uninstall.sh — claude-toolkit
# Gỡ skills + hooks, xóa hook config khỏi settings.json
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
TOOLKIT_SKILLS=(plan plan-edit plan-do review commit debug think handoff research)
TOOLKIT_HOOKS=(privacy-block.sh safety-guard.sh session-init.sh)

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }

echo ""
echo "claude-toolkit uninstaller"
echo "──────────────────────────"

# ── 1. Prereqs ────────────────────────────────────────────────────────────────
command -v jq >/dev/null 2>&1 || { warn "jq không có — bỏ qua bước clean settings.json"; }

# ── 2. Xóa skills ─────────────────────────────────────────────────────────────
for skill in "${TOOLKIT_SKILLS[@]}"; do
  target="$CLAUDE_DIR/skills/$skill"
  if [ -d "$target" ]; then
    rm -rf "$target"
    ok "Removed skill: $skill"
  fi
done

# ── 3. Xóa hooks ──────────────────────────────────────────────────────────────
for hook in "${TOOLKIT_HOOKS[@]}"; do
  target="$CLAUDE_DIR/hooks/$hook"
  if [ -f "$target" ]; then
    rm -f "$target"
    ok "Removed hook: $hook"
  fi
done

# ── 4. Xóa hook config khỏi settings.json ────────────────────────────────────
if command -v jq >/dev/null 2>&1 && [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"

  # Xóa hook entries có path chứa ~/.claude/hooks/
  jq '
    if .hooks then
      .hooks |= (
        to_entries |
        map(
          .value |= map(
            .hooks |= map(
              select(.command | test("claude/hooks/(privacy-block|safety-guard|session-init)") | not)
            )
          ) |
          select((.value | length) > 0)
        ) |
        from_entries
      )
    else . end |
    if (.hooks | length) == 0 then del(.hooks) else . end
  ' "$SETTINGS" > /tmp/ct_settings_clean.json

  mv /tmp/ct_settings_clean.json "$SETTINGS"
  ok "Hook config đã xóa khỏi settings.json"
fi

# ── 5. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────"
echo -e "${GREEN}Gỡ cài đặt hoàn tất.${NC}"
warn "Dữ liệu task (.dw/tasks/) trong các project KHÔNG bị xóa."
echo ""
