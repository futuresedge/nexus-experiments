# Task 1.5 — Human Review

**Input:** `project-manifest.yaml` (status: DRAFT)
**Output:** `project-manifest.yaml` (status: APPROVED); FC-4 audit log entry; `RR-1-01.yaml`

***

### Subtask 1 — Presentation Preparation

**Input:** DRAFT manifest; register (WARNING and INFO entries)
**Output:** Review package — Part 1 (field values) and Part 2 (open questions); `summaryvalidated: true` confirmed before delivery

**Skills**
- Two-part structure — field confirmation and gap acknowledgement are separate asks
- Summary fidelity validation — every summary value checked against source manifest field before delivery
- All open questions presented — no filtering; WARNING entries before INFO
- Approval instruction precision — names exactly what constitutes approval and what constitutes a returned correction

**Failure Modes**
- Part 2 omitted → approval is not informed consent; FC-4 requirement not met
- Summary not validated → rendering error reaches Alex; approval is for a document that doesn't match the canonical file

***

### Subtask 2 — Presentation and Blocking

**Input:** Review package
**Output:** Package delivered; `presentedat` set at moment of delivery; process suspended; `RR-1-01.yaml` filed

**Skills**
- `presentedat` set at moment of delivery — not at response receipt
- Hard blocking — no further Task 1 work; no preparatory work during block
- Review record filed in `.framework/reviews/` — distinct from CE records in `.framework/clarifications/`

**Failure Modes**
- `presentedat` set at response receipt → audit trail misrepresents timeline
- Work performed during block → assumptions embedded; must be undone if actual response differs

***

### Subtask 3 — Response Classification

**Input:** Alex's response; review record
**Output:** `responseclassification: APPROVED | RETURNED | UNCLEAR`; appropriate path initiated

**Skills**
- Full response read before classifying — opening word is not the classification
- Minimum explicit approval threshold — "approved", "confirmed", "yes, that's correct"; not "looks good", "fine", "ok"
- Scope change detection — correction that invalidates a prior BLOCKER resolution reopens affected register entries
- UNCLEAR follow-up — one question, one ambiguity; not original question rephrased

**Failure Modes**
- "Looks good" classified as APPROVED → FC-4 non-compliant; not an explicit deliberate affirmation
- Embedded correction ignored → manifest APPROVED with a field value Alex's last statement contradicted
- Scope change treated as value correction → untraced content enters manifest; mini Task 1.1–1.3 cycle required but not run

***

### Subtask 4 — Correction Application *(conditional)*

**Input:** Alex's returned corrections; current manifest; traceability record
**Output:** Corrected field; new traceability entry (`sourcetype: correction`); old traceability entry retained with `supersedes` reference; `CR-1-xx.yaml`; change summary for re-presentation

**Skills**
- Correction scope containment — only the named field changes; adjacent fields not touched without explicit instruction
- Traceability chain integrity — old entry retained; new entry added with `supersedes`; never replace in-place
- Value correction vs scope addition classification — scope addition requires mini Task 1.1–1.3 cycle before entering manifest
- Change summary for re-presentation — names field, previous value, corrected value; Alex confirms correction only, not full manifest
- `UNSTABLE-FIELD` flag on second correction to same field — request definitive statement before re-presenting

**Failure Modes**
- Old traceability entry deleted → correction history lost; verifier cannot confirm what changed
- Scope addition treated as value correction → untraced content in manifest; Step 2 consequence unassessed
- Full manifest re-presented without change summary → Alex may miss the changed field

***

### Subtask 5 — Approval Recording

**Input:** Alex's APPROVED response; manifest; traceability record; `humanactors` entry
**Output:** `status: APPROVED`; `approvedat`; `approvedby`; FC-4 Tier 1 audit log entry; `RR-1-01.yaml` completed

**Skills**
- `approvedby` exact-match validation — use `humanactors[].name` value, not name as signed in response
- `approvedat` as human action timestamp — datetime of Alex's response, not executor processing time
- `approvalstatement` verbatim, minimum 5 words — Alex's actual words; not a template
- Post-approval immutability — no writes to manifest or traceability record after APPROVED; corrections require return to DRAFT
- Audit log entry as independent evidence — distinct from `status` field; both must exist

**Failure Modes**
- `approvedat` set to executor processing time → timeline misrepresented in audit trail
- `approvedby: "humandirector"` — role title not a name; not independently verifiable; FC-4 non-compliant


- Traceability companion record edited post-approval → APPROVED state no longer fully intact; verifier finds post-seal modification 