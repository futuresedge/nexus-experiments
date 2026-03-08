# Part 5 — Skill Requirements by Task

Compiled from all subtask analyses. These are the loaded prerequisites an executor must have before beginning each task.

Skills Compendium for Task 1.1

| Subtask | Critical skill | Most consequential failure |
|---|---|---|
| 1 — Full read | Read-before-classify discipline | Implicit contradiction silently resolved during read |
| 2 — Statement extraction | Statement atomisation; implicit statement recognition | Compound statements collapsed; implicit dependency missed |
| 3 — Required field coverage | Format-rule knowledge per field; multi-statement assembly detection | PRESENT assigned for format-non-compliant values |
| 4 — Optional field coverage | Restraint (ABSENT is complete); `constraints`/`outofscope` format rule knowledge | Inferred constraints recorded as PRESENT |
| 5 — Non-mappable identification | Schema exhaustion check; downstream consequence assessment | Non-mappable array incomplete; vague `downstream_note` |
| 6 — Contradiction detection | Domain knowledge; non-resolution discipline; multi-field impact enumeration | Domain-knowledge contradiction silently resolved |

## Task 1.2

- Step 2 and Step 3 policy documents loaded as reference — Gate 1 cannot be applied without them
- FC-2 three-tier classification and Gate sequence
- Manifest schema — required vs optional field distinction, conditional requirement rules
- One-gap-one-entry discipline — if two gaps produce different clarification questions, they are different entries
- Domain knowledge of the declared tech stack — to detect domain-level contradictions

## Task 1.3

- `gap_type` → question type mapping (AMBIGUOUS-INCOMPLETE → value-retrieval; AMBIGUOUS-FORMAT → choice; CONTRADICTION → disambiguation)
- FC-3 compound question prohibition — one sentence, max 25 words, one gap per question
- FC-3 batch delivery rule — all questions in one exchange
- Linked group detection procedure — check `linked_questions` before formulating any question
- Response classification taxonomy before any register write
- Linked cascade execution after each `RESOLVED` response

## Task 1.4

- Pre-drafting derivation resolution — derivation_flag query before field one
- Version lookup capability or defined fallback when unavailable
- Step 2 schema knowledge — to detect implicit dependencies (e.g. `@astrojs/react`) during population
- Traceability-alongside-field discipline — one operation, two writes
- Description assembly rule — fidelity to brief language, no editorial voice
- Conditional sections table (S-05) — or equivalent domain knowledge

## Task 1.5

- Summary fidelity validation — deterministic rendering, value-by-value check before delivery
- Minimum explicit approval threshold — must be a loaded definition, not a judgment call
- Scope change detection — must know which register entries were used to resolve prior BLOCKERs
- Post-approval immutability — no writes to manifest or traceability record after APPROVED
