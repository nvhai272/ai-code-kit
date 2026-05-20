# claude-toolkit

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
git clone https://github.com/<your-username>/claude-toolkit.git ~/projects/claude-toolkit

# 3. Cài vào ~/.claude/
cd ~/projects/claude-toolkit
bash install.sh
```

`install.sh` sẽ:
- Backup skills cũ → `~/.claude/skills.bak.YYYYMMDDHHMMSS/`
- Copy 7 skills → `~/.claude/skills/`
- Copy 3 hooks → `~/.claude/hooks/`
- Merge hook config → `~/.claude/settings.json`

Gỡ cài đặt: `bash uninstall.sh` (không xóa task data trong `ai-code-kit/tasks/`)

---

## Workflow

### Sơ đồ tổng quan

```
[task phức tạp]                    [task đơn giản]
      ↓                                   ↓
  /research                            /plan
      ↓                                   ↓
    /plan  ──────────────────────────  /plan-edit
      ↓                                   ↓
  /plan-edit                          [approve]
      ↓                                   ↓
  [approve]                           /plan-do ←──┐
      ↓                                   ↓       │
  /plan-do ←──┐                        /review    │ (subtask tiếp)
      ↓       │ (subtask tiếp)                    │
   /review    │                                   └──
              └──

Bất kỳ lúc nào:  /debug · /think
```

### Ví dụ thực tế: Feature "thêm tính năng đăng nhập"

```bash
# Bước 1: Tạo branch mới
git checkout -b feat/user-login

# Bước 2: Khởi tạo task
/plan
# → Tạo ai-code-kit/tasks/feat-user-login/spec.md + tracking.md

# Bước 3: Nhập mô tả vào spec.md → ## Intent
# "Thêm luồng đăng nhập bằng email/password với JWT token,
#  bảo vệ các route cần auth, lưu session 7 ngày."

# Bước 4: Research codebase (nếu project lớn)
/research feat-user-login
# → Scan auth patterns, existing middleware, DB schema

# Bước 5: Generate plan
/plan-edit
# → Sinh ST-1 đến ST-N, risks, success criteria
# → Hiển thị plan, CHỜ bạn gõ "ok"

# Bước 6: Implement từng subtask
/plan-do
# → Làm ST-1, dừng lại, chờ xác nhận
# → Làm ST-2, dừng lại, chờ xác nhận...

# Bước 7: Review code
/review
# → Báo cáo CRITICAL / WARNING / SUGGESTION

# Khi cần debug:
/debug "JWT token bị expire sớm hơn 7 ngày"

# Khi cần nghĩ sâu hơn:
/think "Nên dùng refresh token hay sliding session?"
```

### Quy tắc quan trọng

| Quy tắc | Lý do |
|---------|-------|
| Mỗi subtask chờ xác nhận trước khi sang cái tiếp | Tránh AI tự ý làm quá scope |
| `## Intent` trong spec.md không bao giờ bị sửa | Là nguồn gốc, không được drift |
| Subtask đã Done không bị xóa | Lịch sử không thể xóa |
| Mỗi subtask chờ xác nhận trước khi commit | Tránh commit nhầm |

---

## Skills — Hướng dẫn chi tiết

### `/plan` — Khởi tạo task

**Khi dùng:** Bắt đầu một feature/bugfix mới, chưa có task docs.

**Cách dùng:**
```
/plan
```
Không cần argument — tự detect branch hiện tại.

**Output:** Tạo 2 files trong `ai-code-kit/tasks/{branch-slug}/`:
- `spec.md` — chứa Intent (bạn điền), Scope, Risks, Success Criteria
- `tracking.md` — bảng tiến độ subtasks, changelog, handoff notes

**Sau đó:** Mở `spec.md`, viết mô tả vào `## Intent`, rồi chạy `/plan-edit`.

---

### `/plan-edit` — Generate kế hoạch

**Khi dùng:** Sau khi đã nhập Intent, muốn AI generate subtasks + risks.  
Cũng dùng để **cập nhật plan** khi scope thay đổi giữa chừng.

**Cách dùng:**
```
/plan-edit
```

**Quá trình AI làm:**
1. Đọc Intent → phân tích codebase (Grep/Glob)
2. Đặt 3 câu hỏi: *Giả định nào? Side effects? Edge cases?*
3. Generate subtasks (ST-1, ST-2...) với files, acceptance, effort
4. Viết Risks & Mitigations, Success Criteria
5. Hiển thị plan → **dừng chờ bạn approve**

**Approve:** Gõ `"ok"` hoặc feedback cụ thể để điều chỉnh.

**Lưu ý:** Chỉ ghi vào `spec.md` và `tracking.md`, không chạm vào code.

---

### `/plan-do` — Thực hiện

**Khi dùng:** Sau khi plan đã approved, muốn AI implement từng subtask.

**Cách dùng:**
```
/plan-do
```

**Quá trình:**
1. Tìm ST đầu tiên `⬜ Pending`
2. Đọc files liên quan → báo danh sách files sẽ thay đổi → chờ xác nhận
3. Implement
4. Báo cáo kết quả → **dừng chờ xác nhận** trước khi sang ST tiếp
5. Sau xác nhận: cập nhật `tracking.md` (tick Done, ghi changelog)

**Xác nhận:** Gõ `"ok"` / `"tiếp"` / `"được"` để sang subtask tiếp.  
Hoặc gõ feedback để AI điều chỉnh trước khi tiếp tục.

**Nếu phát hiện vấn đề ngoài scope:** AI dừng, báo cáo, chờ quyết định — không tự mở rộng.

---

### `/plan-edit` và `/plan-do` — Phân biệt

| | `/plan-edit` | `/plan-do` |
|---|---|---|
| Làm gì | Phân tích + viết plan | Implement code |
| Chạm vào code | Không | Có |
| Output | spec.md được điền đầy đủ | Code changes + tracking.md updated |
| Khi nào | Trước khi code | Sau khi plan approved |

---

### `/review` — Code review

**Khi dùng:** Sau khi implement xong (một subtask hoặc cả task), trước khi commit/merge.

**Cách dùng:**
```
/review
```
Tự detect branch và base branch — review uncommitted changes hoặc toàn bộ commits trên branch.

**Output 3 mức:**
- 🔴 **CRITICAL** — phải sửa trước khi merge (logic sai, security, data loss)
- 🟡 **WARNING** — nên sửa (performance, error handling thiếu)
- 🔵 **SUGGESTION** — cân nhắc (refactor, naming, style)

**Sau review:**
- Có Critical → sửa xong chạy lại `/review`
- Chỉ Warning → có thể commit, ghi nhận warning
- Pass → approved, commit

**Lưu ý:** Review chỉ đọc và báo cáo — không tự sửa code.

---

### `/research` — Khảo sát codebase

**Khi dùng:** Trước `/plan-edit` khi task phức tạp, chạm nhiều files, hoặc bạn chưa quen codebase.

**Cách dùng:**
```
/research feat-user-login
/research "thêm payment gateway"
```

**AI làm gì:**
- Grep patterns liên quan, đọc files key
- `git log/blame` xem ai đã thay đổi gì
- Vẽ dependency map: files sẽ thay đổi + files bị ảnh hưởng
- Phát hiện cạm bẫy, conventions cần follow

**Output:** Ghi vào `spec.md` section `## Research Findings`.  
Sau đó chạy `/plan-edit` để generate plan dựa trên findings này.

---

### `/debug` — Debug có hệ thống

**Khi dùng:** Gặp lỗi, test fail, behavior bất thường.

**Cách dùng:**
```
/debug "TypeError: Cannot read property 'id' of undefined ở line 42"
/debug "API trả 500 khi POST /orders nhưng chỉ xảy ra với user có role admin"
```

**3 phases:**
1. **Observe** — thu thập symptoms, reproduction steps, môi trường
2. **Hypothesize** — đặt top 3 nguyên nhân có thể, sắp xếp theo xác suất
3. **Fix** — impact analysis callers, verify root cause, regression check callers và test bao phủ (hoặc thông báo danh sách cần test thủ công)

**Nguyên tắc:** Không sửa nhiều thứ cùng lúc — 1 hypothesis → 1 fix → 1 verify.

---

### `/think` — Tư duy phản biện

**Khi dùng:** Task có nhiều hướng giải quyết, rủi ro cao, hoặc cần quyết định kiến trúc.

**Cách dùng:**
```
/think "Nên dùng WebSocket hay polling cho real-time notifications?"
/think "Migrate từ MySQL sang PostgreSQL có nên làm không?"
```

**3 lens:**
- **Critical** — giả định đang dùng là gì? Có thể sai ở đâu? Top 3 risks?
- **Systems** — side effects, data flow, feedback loops
- **Perspectives** — góc nhìn User / Dev / Ops / Security

**Output:** Bảng phân tích + đề xuất có lý do rõ ràng + trade-offs.

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
| `rm -rf /`, `rm -rf *`, `rm -rf .` | `DROP TABLE` (cảnh báo, hỏi) |
| `git push --force` lên main/master/develop | `git push --force` lên branch khác |
| `DELETE FROM` không có `WHERE` | |
| `UPDATE ... SET` không có `WHERE` | |

### `session-init` — Nhắc task đang làm

Mỗi khi mở session mới trong project có task đang `In Progress`:

```
---
[claude-toolkit] Task đang In Progress:
  • feat-user-login — ST-3: Viết auth middleware | Next: test với Postman
Tiếp tục với /plan-do để xem context đầy đủ.
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
status: Approved        # Draft → Approved sau khi /plan-edit approve
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
← /research ghi vào đây
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
        └── review/
            └── SKILL.md   ← Claude dùng cái này thay vì global
```

Claude Code ưu tiên **project-level > global**.

### Ví dụ: Override `/review` cho project PHP/Laravel

Tạo `.claude/skills/review/SKILL.md` trong project với thêm rules:

```markdown
---
name: review
description: Review code Laravel. Extends global review với PHP-specific checks.
---

# Code Review (Laravel)

<!-- Giữ toàn bộ nội dung global review, thêm section: -->

## PHP/Laravel Specific

**🔴 CRITICAL thêm:**
- N+1 query không dùng `with()` eager loading
- Raw query không dùng prepared statements
- Mass assignment không có `$fillable`

**🟡 WARNING thêm:**
- Logic trong Controller thay vì Service layer
- Không dùng Form Request để validate
- Response không wrap trong Resource class
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

### `/plan-do` báo "Plan chưa được approve"
Mở `spec.md`, kiểm tra frontmatter:
```yaml
status: Approved    ← phải là Approved, không phải Draft
```
Nếu vẫn là `Draft` → chạy `/plan-edit` và gõ `"ok"` để approve.

### `/review` không có output
- **Có uncommitted changes**: `/review` tự dùng working tree mode — không cần commit
- **Không có uncommitted changes**: cần ít nhất 1 commit trên branch so với base branch:
```bash
git log --oneline main..HEAD    # hoặc develop..HEAD tuỳ base branch của project
```

---

## Push lên GitHub & Update

### Push lần đầu

```bash
cd ~/projects/claude-toolkit

# Dùng GitHub CLI (khuyến nghị)
gh repo create claude-toolkit --public --source=. --remote=origin --push

# Hoặc thủ công
git remote add origin https://github.com/<username>/claude-toolkit.git
git push -u origin main
```

### Update toolkit

```bash
cd ~/projects/claude-toolkit
git pull origin main
bash install.sh    # cài lại version mới
```

### Customize và giữ khi pull

Nếu bạn sửa skill global và muốn giữ khi update: đặt version riêng của bạn vào `.claude/skills/` của **project** thay vì sửa trực tiếp trong toolkit repo.

---

*claude-toolkit v1.2.0*
