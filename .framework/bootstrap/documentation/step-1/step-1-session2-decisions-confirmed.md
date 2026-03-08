# Part 1 — Decisions Confirmed This Session

These were confirmed at the start and treated as fixed throughout the analysis.

| ID | Decision | Effect |
|---|---|---|
| **D-01** | Vocabulary: `BLOCKER / WARNING / INFO` (three tiers) | Replaces policy's `BLOCKING / OPENQUESTION / WARNING / LOWRISK` across all Task 1.x analysis |
| **D-02** | "OPENQUESTION" is a role/status, not a severity label | Non-blocking entries are `WARNING` or `INFO`; they carry forward in the register |
| **D-03** | Task 1.2 output is `open-questions-register.yaml` — not a separate ad-hoc gap list | Register created in Task 1.2 and persists through all six steps per FC-8 |
| **D-04** | Task 1.2 input is `brief-inventory.yaml` exactly as shaped in Task 1.1 | All classification work is expressed as queries over its four arrays |
| **D-05** | Task 1.2 has four subtasks — required fields, optional fields, contradictions, non-mappable | Non-mappable classification is an explicit fourth subtask, not implied |
| **DQ-01** | `linked_questions` populated in a single bidirectional pass at end of Subtask 3 — not retroactively during subtask execution | Prevents orphaned linkages and retroactive record updates |
| **DQ-04** | `derivation_flag` retained in exchange record as machine-queryable signal | Redundancy with `resolutionnote` is intentional — one for human reading, one for agent querying |
| **DQ-05** | Derivation worklog folded into traceability record (Option B) | No separate worklog artefact; derivation entries use `sourcetype: derivationrule` in the traceability record |
| **DQ-06** | `pnpm` (and any package manager) may appear in both `techstack` and `devenvironment.packagemanager` | Each field serves a different downstream consumer; duplication is intentional with a single shared source reference |