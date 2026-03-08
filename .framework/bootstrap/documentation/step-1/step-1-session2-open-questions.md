# Part 8 — Open Questions / Unresolved Items

## Unresolved Design Questions (carried forward)

| ID | Question | Stakes | Deferred to |
|---|---|---|---|
| **DQ-02** | Is an INFO entry for `existingassets: ABSENT` worth creating — register noise vs completeness record? | Low | Framework-level decision on register scope: actionable findings only vs complete assessment record |
| **DQ-03** | The Meridian register has 13 entries from a simple brief. A complex brief could produce 30+. Is there a maximum batch size for FC-3 exchanges? Should BLOCKERs be prioritised before WARNINGs? | Medium | FC-3 policy extension |
| **UQ-03** | `DECISION-REQUIRED` handling: when Alex has not decided (not missing declared information), FC-3 does not apply. What framework mechanism handles undecided technical choices? Step blocks until a decision is made — but no protocol is defined for what happens next. | High — blocks Task 1.3 in this scenario | Framework-level; flag for FC-3 extension |

## Questions Confirmed Settled This Session

| ID | Question | Settlement |
|---|---|---|
| **DQ-01** | When does `linked_questions` get populated for Subtask 1 entries created before Subtask 3 runs? | Option B: single bidirectional linking pass at end of Subtask 3 |
| **DQ-04** | Retain `derivation_flag` in exchange record? | Yes — machine-queryable signal for Task 1.4 pre-drafting step |
| **DQ-05** | Derivation worklog as formal artefact or internal only? | Option B: fold into traceability record as `sourcetype: derivationrule` entries |
| **DQ-06** | Should `pnpm` appear in both `techstack` and `devenvironment.packagemanager`? | Yes — duplication intentional, documented in schema, single shared source reference |
