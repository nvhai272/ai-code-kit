---
name: think
description: Áp dụng framework tư duy phản biện trước khi quyết định hoặc implement. Dùng khi task phức tạp, có nhiều hướng, hoặc có rủi ro cao.
argument-hint: "[vấn đề cần phân tích]"
user-invocable: true
---

# Framework Tư Duy

Vấn đề: **$ARGUMENTS**

## Lens 1 — Critical Thinking

**Giả định đang dùng:**
- [ ] Giả định 1 — Cách kiểm chứng: ...
- [ ] Giả định 2 — Cách kiểm chứng: ...

**Top 3 rủi ro:**
| Risk | Xác suất | Tác động | Mitigation |
|------|----------|----------|------------|
| ... | Cao/TB/Thấp | ... | ... |

**Câu hỏi chưa trả lời:** Điều gì tôi chưa biết mà cần biết trước khi tiếp?

## Lens 2 — Systems Thinking

**Side effects:** Thay đổi này ảnh hưởng đến module/service nào khác?
**Data flow:** Data đi qua đâu? Có điểm nào bị break?
**Feedback loops:** Có cycle hay dependency ngược không?

## Lens 3 — Multiple Perspectives

| Góc nhìn | Concern chính | Trade-off |
|----------|---------------|-----------|
| User | ... | ... |
| Developer | ... | ... |
| Ops/Deploy | ... | ... |
| Security | ... | ... |

## Kết luận

**Hướng được đề xuất:** ...
**Lý do:** ...
**Trade-off chấp nhận được:** ...
**Điều cần confirm trước khi làm:** ...
