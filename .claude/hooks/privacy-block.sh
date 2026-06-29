#!/usr/bin/env bash
# privacy-block.sh — ai-code-kit
# Block Claude đọc file nhạy cảm (.env, credentials, private keys)
# PreToolUse hook → Read
# exit 0 = allow | exit 2 = block

INPUT=$(cat)

# Extract tool_name — jq, fallback bash grep nếu jq thiếu/lỗi (tránh fail-open)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
if [ -z "$TOOL_NAME" ]; then
  TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || true)
fi
[ "$TOOL_NAME" != "Read" ] && exit 0

# Extract file_path — jq, fallback bash grep
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || true)
fi
[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename "$FILE_PATH")
NORM=$(echo "$FILE_PATH" | tr '\\' '/')

# ── Allow-list (safe files dù tên giống sensitive) ────────────────────────────
case "$BASENAME" in
  *.example|*.sample|*.template|.env.test|.env.local.example) exit 0 ;;
esac

# ── Block patterns ─────────────────────────────────────────────────────────────
BLOCKED=false
REASON=""

# .env files
if [[ "$BASENAME" == ".env" ]] || [[ "$BASENAME" == .env.* ]]; then
  BLOCKED=true; REASON="Environment file (có thể chứa secrets/API keys)"
fi

# Private keys & certs
if [[ "$BASENAME" == *.pem ]] || [[ "$BASENAME" == *.key ]] || \
   [[ "$BASENAME" == *.p12 ]] || [[ "$BASENAME" == *.pfx ]] || \
   [[ "$BASENAME" == *.jks ]]; then
  BLOCKED=true; REASON="Private key / certificate file"
fi

# SSH private keys (không có extension)
if echo "$BASENAME" | grep -qE '^id_(rsa|ed25519|ecdsa|dsa)$'; then
  BLOCKED=true; REASON="SSH private key"
fi

# Dotfiles chứa credentials (.npmrc, .netrc, .pgpass, .pypirc)
case "$BASENAME" in
  .npmrc|.netrc|.pgpass|.pypirc)
    BLOCKED=true; REASON="Dotfile chứa credentials/auth token" ;;
esac

# Credentials & secrets files
if echo "$BASENAME" | grep -qiE '^(credentials|secrets?|secret[-_]key|api[-_]key|auth[-_]token|access[-_]token)(\.[a-z]+)?$'; then
  BLOCKED=true; REASON="Credentials / secrets file"
fi

# Service account / cloud keys
if echo "$BASENAME" | grep -qiE 'service[-_]account.*\.json$|gcp.*key.*\.json$|firebase.*key.*\.json$'; then
  BLOCKED=true; REASON="Service account / cloud credentials"
fi

# Credentials directory
if echo "$NORM" | grep -qiE '/(credentials|secrets)/'; then
  BLOCKED=true; REASON="Thư mục credentials/secrets"
fi

if [ "$BLOCKED" = true ]; then
  echo "[privacy-block] Blocked: $FILE_PATH" >&2
  echo "  Lý do: $REASON" >&2
  echo "  Nếu cần đọc file này, xác nhận rõ ràng trong prompt." >&2
  exit 2
fi

exit 0
