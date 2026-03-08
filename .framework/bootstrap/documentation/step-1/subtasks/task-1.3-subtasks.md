# Task 1.3 — Clarification Resolution *(conditional — runs only if BLOCKER entries exist)*

**Input:** `open-questions-register.yaml` (BLOCKER entries only); feedback channel to humandirector
**Output:** `CE-1-01.yaml` — exchange record with all BLOCKERs resolved, CONFIRMED-UNKNOWN, or DECISION-REQUIRED

***

### Subtask 1 — Question Formulation and Exchange Record Creation

**Input:** All BLOCKER register entries
**Output:** Exchange record shell with one question per entry (or one question per linked group); `initiatedat` set at moment of send

**Skills**

- `gap_type` → question type mapping: ABSENT → value-retrieval, AMBIGUOUS-INCOMPLETE → value-retrieval with context, AMBIGUOUS-FORMAT → choice with valid options, CONTRADICTION → disambiguation naming both sides
- FC-3 compound question prohibition — one gap per question; 25-word proxy test
- Retrieval instructions permitted (e.g. "run `node --version`") — not compound
- Linked group detection — one question covers all entries in a linked group
- Impact statement drawn verbatim from register `impact` field — not rewritten
- Exchange record shell created before delivery — `initiatedat` set at send, not at receipt

**Failure Modes**
- Compound question for linked entries → two questions for one issue; one response; second entry stays OPEN; Task 1.4 blocked
- AMBIGUOUS-FORMAT treated as AMBIGUOUS-INCOMPLETE → retrieval question sent; Alex re-answers what they already answered
- Exchange record created post-response → `initiatedat` is a reconstruction; audit trail integrity fails
- Impact statement rewritten → precision lost; Alex's response is less targeted

***

### Subtask 2 — Batch Delivery and Blocking

**Input:** Formulated questions; exchange record shell
**Output:** All questions delivered as one batch; process suspended; `initiatedat` confirmed

**Skills**
- Batch delivery — all BLOCKER questions in one exchange, one block, one response cycle
- Hard blocking — no optimistic pre-loading, no parallel manifest work during block
- Question self-containedness — each question answerable without reading the others

**Failure Modes**
- Sequential delivery → multiple round trips; later questions may be made irrelevant by earlier answers
- Partial batch → two exchange records for one Task 1.3 run; FC-8 carry-forward must reconcile split references
- Pre-loading during block → assumptions embedded in work that must be undone if Alex's responses differ

***

### Subtask 3 — Response Classification and Register Update

**Input:** Alex's response; exchange record; register (BLOCKER entries)
**Output:** All BLOCKER entries reclassified (RESOLVED | CONFIRMED-UNKNOWN | DECISION-REQUIRED | UNCLEAR); `resolutionnote` verbatim; `derivation_flag` set; cascade updates applied; FC-9 invoked if DECISION-REQUIRED

**Skills**
- Classification-before-action — full response read before any register entry updated
- `derivation_flag` identification — "latest stable" is a rule acceptance, not a resolved value
- Cascade execution — after each RESOLVED, query `linked_questions[]` and apply same resolution to all linked entries
- UNCLEAR handling — single follow-up question targeting the specific ambiguity; not original question rephrased
- DECISION-REQUIRED routing to FC-9 — FC-3 scope ends here; DR record created; `AWAITING-DECISION` status set
- Verbatim `resolutionnote` — not summarised, not normalised

**Failure Modes**
- Classification on first sentence → embedded correction or uncertainty in later sentence missed; RESOLVED when UNCLEAR
- "Latest stable" recorded as final value → `derivation_flag: false`; manifest entry violates techstack format rule
- Cascade update missed → linked entry stays OPEN; Task 1.4 begins with unresolved BLOCKER
- DECISION-REQUIRED not routed to FC-9 → process hard-blocks with no exit path; Alex has no context to unblock
