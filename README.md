# ai-code-kit

Bộ skills + hooks cá nhân cho [Claude Code](https://claude.ai/code), tối ưu cho Ubuntu/terminal.

**Thiết kế cho:** solo developer · đa công nghệ · giảm token usage · không config file

---

## Mục lục

- [Cài đặt](#cài-đặt)
- [Workflow](#workflow)
- [Skills — Hướng dẫn chi tiết](#skills--hướng-dẫn-chi-tiết)
- [Hooks — Chạy tự động](#hooks--chạy-tự-động)
- [Cấu trúc task files](#cấu-trúc-task-files)
- [Ghi đè skill cho dự án cụ thể](#ghi-đè-skill-cho-dự-án-cụ-thể)
- [Troubleshooting](#troubleshooting)
- [Push lên GitHub & Update](#push-lên-github--update)

---

## Cài đặt

**Yêu cầu:** Ubuntu/Linux · `jq` · Claude Code CLI

```bash
# 1. Cài jq nếu chưa có
sudo apt install jq

# 2. Clone toolkit
git clone https://github.com/<your-username>/ai-code-kit.git ~/projects/ai-code-kit

# 3. Cài vào ~/.claude/
cd ~/projects/ai-code-kit
bash install.sh
```

`install.sh` sẽ:
- Backup skills cũ → `~/.claude/skills.bak.YYYYMMDDHHMMSS/`
- Copy 5 skills → `~/.claude/skills/`
- Copy 3 hooks → `~/.claude/hooks/`
- Merge hook config → `~/.claude/settings.json`

Gỡ cài đặt: `bash uninstall.sh` (không xóa task data trong `ai-code-kit/tasks/`)

---

## Workflow

### Sơ đồ tổng quan

```
[task phức tạp]                    [task đơn giản]
      ↓                                   ↓
  /ai-research                            /ai-plan
      ↓                                   ↓
    /ai-plan  ──────────────────────────  /ai-plan-edit
      ↓                                   ↓
  /ai-plan-edit                          [approve]
      ↓                                   ↓
  [approve]                           /ai-plan-do  ⟳ auto loop hết ST
      ↓                                   ↓        chỉ dừng ở hard-stop
  /ai-plan-do  ⟳ auto loop hết ST         ↓
      ↓                                   →  report.html (review trực quan)
      →  report.html (review trực quan)

Bất kỳ lúc nào:  /ai-debug
```

**Hard-stop của `/ai-plan-do`** (dừng + chờ confirm): install/gỡ dependency, migration/seed/drop DB, destructive ops (`rm -rf`, `git reset --hard`, force push), phát hiện ngoài scope, Intent thiếu thông tin, test/acceptance fail, bug ở ST khác đã Done.

**Reopen task đã Done:** Có feedback/bug mới sau khi task đã `Done` → chạy lại `/ai-plan-edit`. Nó tự reset `tracking.md` → `In Progress`, `spec.md` → `Draft`, và tạo ST mới cho bug (không sửa ST cũ).

### Ví dụ thực tế: Feature "thêm tính năng đăng nhập"

```bash
# Bước 1: Tạo branch mới
git checkout -b feat/user-login

# Bước 2: Khởi tạo task
/ai-plan
# → Tạo ai-code-kit/tasks/feat-user-login/spec.md + tracking.md

# Bước 3: Nhập mô tả vào spec.md → ## Intent
# "Thêm luồng đăng nhập bằng email/password với JWT token,
#  bảo vệ các route cần auth, lưu session 7 ngày."

# Bước 4: Research codebase (nếu project lớn)
/ai-research feat-user-login
# → Scan auth patterns, existing middleware, DB schema

# Bước 5: Generate plan
/ai-plan-edit
# → Sinh ST-1 đến ST-N, risks, success criteria
# → Hiển thị plan, CHỜ bạn gõ "ok"

# Bước 6: Implement — auto-execute toàn bộ subtask
/ai-plan-do
# → Tự chạy ST-1 → ST-2 → ... liên tục, append report.html sau mỗi ST
# → Chỉ DỪNG khi gặp hard-stop (install dep, migration, ngoài scope, test fail...)
# → Khi xong: mở ai-code-kit/tasks/{slug}/report.html để review trực quan

# Khi cần debug:
/ai-debug "JWT token bị expire sớm hơn 7 ngày"
```

### Quy tắc quan trọng

| Quy tắc | Lý do |
|---------|-------|
| `/ai-plan-do` auto chạy liên tục, chỉ dừng ở hard-stop | Cân bằng giữa tự động và an toàn — confirm khi thực sự cần |
| Mỗi ST done → bắt buộc append `report.html` + update `tracking.md` | Có audit trail trực quan để review |
| `## Intent` trong spec.md không bao giờ bị sửa | Là nguồn gốc, không được drift |
| Subtask đã Done không bị xóa | Lịch sử không thể xóa |
| Comment WHY ở luồng phức tạp, không comment WHAT | Code rõ rồi — chỉ note phần non-obvious |
| Task Done + bug/feedback mới → reopen qua `/ai-plan-edit`, tạo ST mới (không sửa ST cũ) | Audit trail rõ, ST Done là bất biến |

---

## Skills — Hướng dẫn chi tiết

### `/ai-plan` — Khởi tạo task

**Khi dùng:** Bắt đầu một feature/bugfix mới, chưa có task docs.

**Cách dùng:**
```
/ai-plan
```
Không cần argument — tự detect branch hiện tại.

**Output:** Tạo 2 files trong `ai-code-kit/tasks/{branch-slug}/`:
- `spec.md` — chứa Intent (bạn điền), Scope, Risks, Success Criteria
- `tracking.md` — bảng tiến độ subtasks, changelog, handoff notes

**Sau đó:** Mở `spec.md`, viết mô tả vào `## Intent`, rồi chạy `/ai-plan-edit`.

---

### `/ai-plan-edit` — Generate kế hoạch

**Khi dùng:** Sau khi đã nhập Intent, muốn AI generate subtasks + risks.  
Cũng dùng để **cập nhật plan** khi scope thay đổi giữa chừng.

**Cách dùng:**
```
/ai-plan-edit
```

**Quá trình AI làm:**
1. Đọc Intent → phân tích codebase (Grep/Glob)
2. Đặt 3 câu hỏi: *Giả định nào? Side effects? Edge cases?*
3. Generate subtasks (ST-1, ST-2...) với files, acceptance, effort
4. Viết Risks & Mitigations, Success Criteria
5. Hiển thị plan → **dừng chờ bạn approve**

**Approve:** Gõ `"ok"` hoặc feedback cụ thể để điều chỉnh.

**Reopen:** Nếu task đã `status: Done` và có feedback/bug mới — tự reset `tracking.md` → `In Progress`, `spec.md` → `Draft`. Bug ở 1 ST cụ thể đã Done → tạo ST mới tham chiếu (`Fix bug ở ST-X`), không sửa ST cũ.

**Lưu ý:** Chỉ ghi vào `spec.md` và `tracking.md`, không chạm vào code.

---

### `/ai-plan-do` — Thực hiện (Auto-Execute)

**Khi dùng:** Sau khi plan đã approved, muốn AI implement toàn bộ subtask một mạch.

**Cách dùng:**
```
/ai-plan-do
```

**Quá trình (auto loop, không hỏi giữa các ST):**
1. Khởi tạo `report.html` (1 lần) trong `ai-code-kit/tasks/{slug}/`
2. Lặp qua ST `⬜ Pending` theo thứ tự. Với mỗi ST:
   - Báo `▶ ST-N` kèm danh sách Files sẽ đổi (trước khi sửa)
   - Đọc files + grep usages (impact analysis)
   - Implement minimal diff. **Comment WHY** ở luồng phức tạp.
   - Chạy test nếu project có config; verify acceptance
   - **Append section vào `report.html`**: Summary + Acceptance, Files changed kèm diff syntax-highlighted, Impact analysis (symbols + callers)
   - Update `tracking.md` (tick Done, changelog) → tiếp ST kế
3. Hết ST → append overview vào `report.html`, set `status: Done`

**Hard-stop — dừng + chờ confirm:**

| Tình huống | Hành động |
|---|---|
| Install/gỡ/upgrade dependency | In command + lý do, chờ "ok" |
| Migration / seed / drop / truncate / alter DB | In SQL/command, chờ "ok" |
| `rm -rf`, `git reset --hard`, force push, xóa branch | In command, chờ "ok" |
| Phát hiện ngoài scope ST | Ghi Changelog, hỏi: thêm ST mới hay skip? |
| Phát hiện bug ở ST khác đã ✅ Done | Dừng, đề xuất `/ai-plan-edit` tạo ST mới — không tự sửa ST cũ |
| Intent thiếu thông tin để quyết định | Hỏi cụ thể, không tự assume |
| Test fail / acceptance không pass | In log, hỏi: debug / rollback / skip? |

**Review:** Mở `ai-code-kit/tasks/{slug}/report.html` bằng browser — diff màu, collapsible, có impact analysis.

---

### `/ai-plan-edit` và `/ai-plan-do` — Phân biệt

| | `/ai-plan-edit` | `/ai-plan-do` |
|---|---|---|
| Làm gì | Phân tích + viết plan | Implement code (auto loop) |
| Chạm vào code | Không | Có |
| Output | spec.md được điền đầy đủ | Code changes + tracking.md + report.html |
| Khi nào | Trước khi code | Sau khi plan approved |
| Dừng khi nào | Chờ approve plan | Chỉ ở hard-stop (xem trên) |

---

### `/ai-research` — Khảo sát codebase

**Khi dùng:** Trước `/ai-plan-edit` khi task phức tạp, chạm nhiều files, hoặc bạn chưa quen codebase.

**Cách dùng:**
```
/ai-research feat-user-login
/ai-research "thêm payment gateway"
```

**AI làm gì:**
- Grep patterns liên quan, đọc files key
- `git log/blame` xem ai đã thay đổi gì
- Vẽ dependency map: files sẽ thay đổi + files bị ảnh hưởng
- Phát hiện cạm bẫy, conventions cần follow

**Output:** Ghi vào `spec.md` section `## Research Findings`.  
Sau đó chạy `/ai-plan-edit` để generate plan dựa trên findings này.

---

### `/ai-debug` — Debug có hệ thống

**Khi dùng:** Gặp lỗi, test fail, behavior bất thường.

**Cách dùng:**
```
/ai-debug "TypeError: Cannot read property 'id' of undefined ở line 42"
/ai-debug "API trả 500 khi POST /orders nhưng chỉ xảy ra với user có role admin"
```

**3 phases:**
1. **Observe** — thu thập symptoms, reproduction steps, môi trường
2. **Hypothesize** — đặt top 3 nguyên nhân có thể, sắp xếp theo xác suất
3. **Fix** — impact analysis callers, verify root cause, regression check callers và test bao phủ (hoặc thông báo danh sách cần test thủ công)

**Nguyên tắc:** Không sửa nhiều thứ cùng lúc — 1 hypothesis → 1 fix → 1 verify.

**Sync task:** Nếu branch hiện tại có active task (`tracking.md` `status: In Progress`) → tự append Changelog vào `tracking.md` sau khi fix xong. Không có active task → bỏ qua, không tạo file mới.

---

## Hooks — Chạy tự động

Hooks chạy **trong background**, không cần gọi thủ công, không tốn token context.

### `privacy-block` — Bảo vệ secrets

Tự động chặn Claude đọc các file nhạy cảm:

| Bị chặn | Được phép |
|---------|-----------|
| `.env`, `.env.production` | `.env.example`, `.env.sample` |
| `*.pem`, `*.key`, `*.p12` | Bất kỳ file code nào |
| `credentials.json` | |
| `service-account*.json` | |
| Thư mục `/credentials/`, `/secrets/` | |

Khi bị chặn:
```
[privacy-block] Blocked: /path/to/.env
  Lý do: Environment file (có thể chứa secrets/API keys)
  Nếu cần đọc file này, xác nhận rõ ràng trong prompt.
```

**Override:** Gõ rõ ràng trong prompt: *"Đọc .env.production để kiểm tra cấu hình"* — Claude sẽ hỏi xác nhận thay vì tự chặn.

### `safety-guard` — Chặn lệnh nguy hiểm

| Bị chặn | Cảnh báo (allow) |
|---------|-----------------|
| `rm -rf /`, `rm -rf *`, `rm -rf .` | `git push --force` lên branch khác |
| `git push --force` lên main/master/develop | |
| `DELETE FROM` không có `WHERE` (qua `psql`/`mysql`/`mariadb`/`sqlite3`/`mongosh`/`mongo`/`redis-cli`/`sqlcmd`/`osql`) | |
| `UPDATE ... SET` không có `WHERE` (qua các DB client trên) | |
| `DROP TABLE` / `DROP DATABASE` / `DROP SCHEMA` (qua các DB client trên) | |

3 pattern SQL trên chỉ check khi command thực sự gọi 1 DB client — tránh false-positive khi chữ DROP/DELETE/UPDATE chỉ là text (commit message, comment, doc...).

### `session-init` — Nhắc task đang làm

Mỗi khi mở session mới trong project có task đang `In Progress`:

```
---
[ai-code-kit] Task đang In Progress:
  • feat-user-login — ST-3: Viết auth middleware | Next: test với Postman
Tiếp tục với /ai-plan-do để xem context đầy đủ.
---
```

Chỉ inject **một lần** mỗi session (không spam mỗi prompt).

---

## Cấu trúc task files

Mỗi task tạo ra 2 files trong `ai-code-kit/tasks/{branch-slug}/`:

### `spec.md` — Stable sau approve

```markdown
---
task_id: feat-user-login
created: 2026-05-20
status: Approved        # Draft → Approved sau khi /ai-plan-edit approve
depth: standard
---

# Spec: feat-user-login

## Intent
← Bạn viết vào đây. AI không bao giờ sửa phần này.

## Scope
### In Scope
**ST-1: Tạo User model và migration**
- Files: database/migrations/create_users.sql, models/User.js
- Acceptance: [ ] Migration chạy không lỗi [ ] Model có validate email/password
- Effort: ~30 phút

**ST-2: ...**

### Out of Scope
- OAuth / social login (task riêng)
- 2FA (phase 2)

## Risks & Mitigations
| Risk | Severity | Mitigation |
|------|----------|------------|
| Password hash cost quá cao gây chậm | Medium | Dùng bcrypt cost=10 |

## Success Criteria
- [ ] Login endpoint trả JWT trong 200ms
- [ ] Token expire đúng 7 ngày

## Research Findings
← /ai-research ghi vào đây
```

### `tracking.md` — Mutable, cập nhật liên tục

```markdown
---
task_id: feat-user-login
status: In Progress
last_updated: 2026-05-20
---

# Tracking: feat-user-login

## Subtask Progress
| # | Subtask | Status | Date | Notes |
|---|---------|--------|------|-------|
| ST-1 | Tạo User model | ✅ Done | 2026-05-20 | migration abc1234 |
| ST-2 | JWT middleware | 🟡 In Progress | | |
| ST-3 | Auth routes | ⬜ Pending | | |

## Changelog
### 2026-05-20 — ST-1 complete
**Actions taken:** Tạo migration + User model với bcrypt

## Handoff Notes
### 2026-05-20 15:30 — Session End
**Đã làm:** ST-1 hoàn thành
**Bước tiếp theo:** Viết JWT middleware, test với secret key từ config
**Context:** Dùng jsonwebtoken v9, không dùng v8 (breaking changes)
```

---

## Ghi đè skill cho dự án cụ thể

Skills ở `~/.claude/skills/` là **global**. Khi cần hành vi khác cho một project cụ thể, tạo skill cùng tên trong project:

```
your-project/
└── .claude/
    └── skills/
        └── ai-plan-do/
            └── SKILL.md   ← Claude dùng cái này thay vì global
```

Claude Code ưu tiên **project-level > global**.

### Ví dụ: Override `/ai-plan-do` cho project PHP/Laravel

Tạo `.claude/skills/ai-plan-do/SKILL.md` trong project với thêm rules:

```markdown
---
name: ai-plan-do
description: Thực hiện task Laravel. Extends global ai-plan-do với PHP-specific conventions.
---

# Thực Hiện Implementation (Laravel)

<!-- Giữ toàn bộ nội dung global ai-plan-do, thêm section: -->

## PHP/Laravel Specific

**Conventions bắt buộc khi implement:**
- Eager load (`with()`) để tránh N+1 query
- Dùng prepared statements / Eloquent, không raw query
- Khai báo `$fillable` cho mass assignment
- Logic ở Service layer, không nhồi vào Controller
- Validate qua Form Request, response wrap trong Resource class
```

### Ví dụ: Tắt hook cho project cụ thể

Tạo `.claude/settings.json` trong project:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": []
      }
    ]
  }
}
```
Hook rỗng sẽ override global hook `privacy-block` — cho phép đọc tất cả files trong project này.

---

## Troubleshooting

### `install.sh: jq not found`
```bash
sudo apt install jq
```

### Hook không chạy sau khi cài
Kiểm tra settings.json có hook config chưa:
```bash
cat ~/.claude/settings.json | jq '.hooks'
```
Nếu `null` → chạy lại `bash install.sh`.

### `privacy-block` chặn nhầm file cần đọc
Gõ rõ ràng trong prompt:
```
Tôi cần đọc .env để kiểm tra DATABASE_URL, hãy đọc file đó cho tôi.
```
Claude sẽ hỏi xác nhận thay vì tự chặn.

### `session-init` inject liên tục không dừng
Xóa marker file cũ:
```bash
rm /tmp/ct-session-*
```

### Skill không được nhận diện sau khi cài
Restart Claude Code (skills được load khi khởi động). Kiểm tra file tồn tại:
```bash
ls ~/.claude/skills/
```

### `install.sh` báo `settings.json` bị hỏng sau merge
Restore từ backup:
```bash
ls ~/.claude/settings.json.bak.*    # tìm backup gần nhất
cp ~/.claude/settings.json.bak.YYYYMMDD ~/.claude/settings.json
```
Chạy lại `install.sh`.

### `/ai-plan-do` báo "Plan chưa được approve"
Mở `spec.md`, kiểm tra frontmatter:
```yaml
status: Approved    ← phải là Approved, không phải Draft
```
Nếu vẫn là `Draft` → chạy `/ai-plan-edit` và gõ `"ok"` để approve.

---

## Push lên GitHub & Update

### Push lần đầu

```bash
cd ~/projects/ai-code-kit

# Dùng GitHub CLI (khuyến nghị)
gh repo create ai-code-kit --public --source=. --remote=origin --push

# Hoặc thủ công
git remote add origin https://github.com/<username>/ai-code-kit.git
git push -u origin main
```

### Update toolkit

```bash
cd ~/projects/ai-code-kit
git pull origin main
bash install.sh    # cài lại version mới
```

### Customize và giữ khi pull

Nếu bạn sửa skill global và muốn giữ khi update: đặt version riêng của bạn vào `.claude/skills/` của **project** thay vì sửa trực tiếp trong toolkit repo.

---

*ai-code-kit v1.6.2*
