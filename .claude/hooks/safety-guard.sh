#!/usr/bin/env bash
# safety-guard.sh — claude-toolkit
# Block các lệnh Bash nguy hiểm trước khi chạy
# PreToolUse hook → Bash
# exit 0 = allow (có thể warn) | exit 2 = block

INPUT=$(cat)

# Extract command — pure bash, không cần jq
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | sed 's/"command"[[:space:]]*:[[:space:]]*"//;s/"$//' | head -1)

[ -z "$COMMAND" ] && exit 0

# ── Pattern 1: rm -rf với path quá rộng ──────────────────────────────────────
# Block: rm -rf / | rm -rf * | rm -rf .
# Allow: rm -rf ./specific/path
if echo "$COMMAND" | grep -qE 'rm\s+-[rf]{1,2}\s+(\/\s*$|\*|\.(\s|$))'; then
  echo "[safety-guard] BLOCKED: rm -rf với path nguy hiểm" >&2
  echo "  Command: $COMMAND" >&2
  echo "  Chỉ định path cụ thể hơn để proceed." >&2
  exit 2
fi

# ── Pattern 2: git push --force lên protected branches ───────────────────────
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force'; then
  BRANCH=$(echo "$COMMAND" | grep -oE '(main|master|develop|dev|release)' | head -1)
  if [ -n "$BRANCH" ]; then
    echo "[safety-guard] BLOCKED: git push --force lên $BRANCH" >&2
    echo "  Force push lên protected branch không được phép." >&2
    exit 2
  fi
  echo "[safety-guard] WARNING: git push --force lên non-protected branch" >&2
  echo "  Proceed nếu intentional." >&2
  exit 0
fi

# ── Pattern 3: Destructive SQL không có WHERE ─────────────────────────────────
if echo "$COMMAND" | grep -qiE '(DELETE\s+FROM|UPDATE\s+\w+\s+SET)' \
   && ! echo "$COMMAND" | grep -qi 'WHERE'; then
  echo "[safety-guard] BLOCKED: Destructive SQL không có WHERE clause" >&2
  echo "  Thêm WHERE clause hoặc confirm intentional." >&2
  exit 2
fi

# ── Pattern 4: DROP TABLE / DROP DATABASE ────────────────────────────────────
if echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE|SCHEMA)'; then
  echo "[safety-guard] WARNING: DROP statement detected" >&2
  echo "  Command: $COMMAND" >&2
  echo "  Đây có phải migration đã được review?" >&2
  exit 0
fi

exit 0
