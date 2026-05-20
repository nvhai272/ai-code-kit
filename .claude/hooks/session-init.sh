#!/usr/bin/env bash
# session-init.sh — claude-toolkit
# Inject task đang In Progress vào đầu session để tránh "session amnesia"
# UserPromptSubmit hook
# Stdout output → inject vào context của user prompt

INPUT=$(cat)

# ── Extract session_id (jq với fallback bash) ─────────────────────────────────
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""' 2>/dev/null)

# Fallback: pure bash grep nếu jq fail
if [ -z "$SESSION_ID" ]; then
  SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | cut -d'"' -f4 2>/dev/null || true)
fi

# Fallback: stable ID theo project dir + giờ (POSIX cksum)
if [ -z "$SESSION_ID" ]; then
  _hash=$(pwd | cksum | cut -d' ' -f1)
  SESSION_ID="fallback-${_hash}-$(date +%Y%m%d-%H)"
fi

# ── Chỉ chạy một lần mỗi session ─────────────────────────────────────────────
SESSION_MARKER="/tmp/ct-session-${SESSION_ID}"
[ -f "$SESSION_MARKER" ] && exit 0
touch "$SESSION_MARKER" 2>/dev/null || true

# ── Scan .dw/tasks/ tìm tasks In Progress (v2 format) ────────────────────────
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TASKS_DIR="$PROJECT_DIR/.dw/tasks"

[ ! -d "$TASKS_DIR" ] && exit 0

ACTIVE=()

while IFS= read -r tracking_file; do
  # Kiểm tra status: In Progress trong frontmatter
  if grep -q '^status: In Progress' "$tracking_file" 2>/dev/null; then
    task_name=$(basename "$(dirname "$tracking_file")")

    # Lấy subtask đang In Progress
    current_st=$(grep '🟡 In Progress' "$tracking_file" 2>/dev/null \
      | grep -oE 'ST-[0-9]+[^|]*' | head -1 | xargs 2>/dev/null || echo "")

    # Lấy bước tiếp theo từ Handoff Notes
    next_step=$(awk '/## Handoff Notes/{found=1} found && /Bước tiếp theo:/{print; exit}' \
      "$tracking_file" 2>/dev/null \
      | sed 's/.*Bước tiếp theo://' | xargs 2>/dev/null || echo "")

    summary="$task_name"
    [ -n "$current_st" ] && summary="$summary — $current_st"
    [ -n "$next_step"  ] && summary="$summary | Next: $next_step"
    ACTIVE+=("$summary")
  fi
done < <(find "$TASKS_DIR" -maxdepth 2 -name "tracking.md" 2>/dev/null)

[ ${#ACTIVE[@]} -eq 0 ] && exit 0

# ── Output context ────────────────────────────────────────────────────────────
echo ""
echo "---"
echo "[claude-toolkit] Task đang In Progress:"
for item in "${ACTIVE[@]}"; do
  echo "  • $item"
done
if [ ${#ACTIVE[@]} -eq 1 ]; then
  task_slug=$(echo "${ACTIVE[0]}" | cut -d' ' -f1)
  echo "Tiếp tục với /plan-do hoặc /handoff để xem context đầy đủ."
else
  echo "Nhiều tasks active — hỏi user muốn tiếp tục task nào."
fi
echo "---"
echo ""

exit 0
