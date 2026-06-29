#!/usr/bin/env bash
# safety-guard.sh — ai-code-kit
# Block các lệnh Bash nguy hiểm trước khi chạy
# PreToolUse hook → Bash
# exit 0 = allow (có thể warn) | exit 2 = block

INPUT=$(cat)

# Extract command — jq xử lý escaped quote đúng; fallback bash grep nếu jq lỗi
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
if [ -z "$COMMAND" ]; then
  COMMAND=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || true)
fi

[ -z "$COMMAND" ] && exit 0

# ── Pattern 1: rm recursive nhắm path quá rộng ───────────────────────────────
# Bắt cờ recursive (-r/-R/-rf/-fr/--recursive) ở MỌI thứ tự, không bắt buộc -f.
# Block path nguy hiểm: / | /* | * | . | ~ | $HOME | thư mục hệ thống.
# Thư mục hệ thống chỉ chặn khi là TARGET trực tiếp (vd `rm -rf /home`), KHÔNG
# chặn subpath (`rm -rf /home/user/project/node_modules` vẫn được phép).
# Allow: rm -rf ./specific/path , rm -rf node_modules
if echo "$COMMAND" | grep -qE '\brm\b' \
   && echo "$COMMAND" | grep -qE '(-[a-zA-Z]*[rR]|--recursive)' \
   && echo "$COMMAND" | grep -qE '(\s|=)(\/\s*$|\/\*|\*\s|\*\s*$|\.(\s|$)|~(\/|\s|$)|\$\{?HOME\}?|\/(etc|usr|bin|sbin|var|boot|lib|lib64|sys|proc|dev|root|home|opt)\/?(\s|$))'; then
  echo "[safety-guard] BLOCKED: rm recursive nhắm path nguy hiểm (/, *, ., ~, \$HOME, thư mục hệ thống)" >&2
  echo "  Command: $COMMAND" >&2
  echo "  Chỉ định path cụ thể, an toàn hơn để proceed." >&2
  exit 2
fi

# ── Pattern 2: git push force lên protected branches ─────────────────────────
# Match: --force, --force-with-lease, -f (short flag), hoặc +refspec
IS_FORCE=false
if echo "$COMMAND" | grep -qE 'git\s+push\b.*(--force(-with-lease)?|\s-[a-zA-Z]*f(\s|$))'; then
  IS_FORCE=true
elif echo "$COMMAND" | grep -qE 'git\s+push\s+\S+\s+\+\S+'; then
  IS_FORCE=true
fi

if [ "$IS_FORCE" = true ]; then
  # Chỉ match branch khi là token độc lập (đầu dòng/space ... space/$/:/),
  # tránh false-positive với 'feature/dev-tools' (chữ 'dev' là chuỗi con).
  BRANCH=$(echo "$COMMAND" \
    | grep -oE '([[:space:]]|^)(main|master|develop|dev|release)([[:space:]/:]|$)' \
    | head -1 | grep -oE '(main|master|develop|dev|release)')
  if [ -n "$BRANCH" ]; then
    echo "[safety-guard] BLOCKED: git push force lên $BRANCH" >&2
    echo "  Command: $COMMAND" >&2
    echo "  Force push lên protected branch không được phép." >&2
    exit 2
  fi
  echo "[safety-guard] WARNING: git push force lên non-protected branch" >&2
  echo "  Proceed nếu intentional." >&2
  exit 0
fi

# ── DB client invocation guard (cho Pattern 3 & 4) ────────────────────────────
# SQL chỉ thực sự CHẠY khi đi qua 1 DB client/migration tool. Nếu không, chữ
# DROP/DELETE/UPDATE chỉ là text thường (commit message, comment, doc...) —
# tránh false-positive bằng cách chỉ check khi command có gọi 1 trong các tool sau.
IS_DB_INVOKE=false
if echo "$COMMAND" | grep -qE '\b(psql|mysql|mariadb|sqlite3|mongosh|mongo|redis-cli|sqlcmd|osql)\b'; then
  IS_DB_INVOKE=true
fi

# ── Pattern 3: Destructive SQL không có WHERE ─────────────────────────────────
if [ "$IS_DB_INVOKE" = true ] \
   && echo "$COMMAND" | grep -qiE '(DELETE\s+FROM|UPDATE\s+\w+\s+SET)' \
   && ! echo "$COMMAND" | grep -qi 'WHERE'; then
  echo "[safety-guard] BLOCKED: Destructive SQL không có WHERE clause" >&2
  echo "  Thêm WHERE clause hoặc confirm intentional." >&2
  exit 2
fi

# ── Pattern 4: DROP TABLE / DROP DATABASE ────────────────────────────────────
if [ "$IS_DB_INVOKE" = true ] \
   && echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE|SCHEMA)'; then
  echo "[safety-guard] BLOCKED: DROP statement detected" >&2
  echo "  Command: $COMMAND" >&2
  echo "  Destructive — confirm intentional trước khi proceed." >&2
  exit 2
fi

# ── Pattern 5: Đọc/copy file nhạy cảm qua Bash (bịt bypass của privacy-block) ──
# privacy-block.sh chỉ chặn tool Read. Bash 'cat .env' vẫn lọt → chặn ở đây.
# Match TÊN FILE cụ thể (.env, *.pem, id_rsa, .npmrc...), không match chữ chung.
# Bỏ qua file mẫu an toàn (*.example/*.sample/*.template).
if echo "$COMMAND" | grep -qE '\b(cat|less|more|head|tail|nl|xxd|od|strings|base64|cp|scp|rsync|grep|egrep|fgrep|rg|awk|sed)\b' \
   && ! echo "$COMMAND" | grep -qiE '\.(example|sample|template)([[:space:]]|$)' \
   && echo "$COMMAND" | grep -qiE '(^|[[:space:]/])\.env(\.[a-z]+)?([[:space:]]|$)|\.(pem|key|p12|pfx|jks)([[:space:]]|$)|\b(id_rsa|id_ed25519|id_ecdsa|id_dsa)\b|(^|/)\.(npmrc|netrc|pgpass|pypirc)([[:space:]]|$)'; then
  echo "[safety-guard] BLOCKED: đọc/copy file nhạy cảm qua Bash" >&2
  echo "  Command: $COMMAND" >&2
  echo "  Dùng tool Read (có privacy-block) hoặc confirm rõ ràng trong prompt." >&2
  exit 2
fi

exit 0
