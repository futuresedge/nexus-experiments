# Part 7 — Done When Conditions

## Task 1.2

1. `open-questions-register.yaml` exists at `.framework/open-questions-register.yaml`
2. Every `fields[]` entry with coverage `ABSENT` or `AMBIGUOUS-*` has a corresponding register entry
3. Every `contradictions[]` entry has a `BLOCKER` register entry
4. Every `non_mappable[]` entry has either a register entry or a documented no-entry decision in the executor's worklog
5. All `linked_questions` fields are bidirectionally populated — completed in the linking pass at end of Subtask 3
6. All entries have `resolutionstatus: OPEN` and `currentowner: 1`

## Task 1.3

1. `CE-1-01.yaml` exists at `.framework/clarifications/` with `respondedat` populated
2. Every question in the exchange record has a corresponding response entry
3. Every BLOCKER register entry has `resolutionstatus` of `RESOLVED`, `CONFIRMED-UNKNOWN`, or `DECISION-REQUIRED` — no remaining `OPEN` BLOCKER entries
4. All `RESOLVED` entries have a `resolutionnote` specific enough to populate the manifest field, or flagged as a named derivation with `derivation_flag: true`
5. All linked entry cascades have been applied — no linked pair with mismatched resolution statuses
6. `CONFIRMED-UNKNOWN` entries have been reclassified from BLOCKER to WARNING per FC-2 downgrade rules

## Task 1.4

1. `project-manifest.yaml` exists at `.framework/project-manifest.yaml` with `status: DRAFT`
2. All required fields are non-empty
3. No `techstack` entry contains a placeholder value (`latest stable`, `TBD`, `x.x`)
4. All optional fields are present — populated with confirmed values, or explicitly recorded as `[]` / `null`
5. All `OPEN` register entries with classification `WARNING` or `INFO` appear in the manifest's `openquestions` field
6. `project-manifest.traceability.yaml` exists and covers every non-empty field
7. All 15 self-check items passed before `status: DRAFT` was set
8. `approvedat` and `approvedby` are absent

## Task 1.5

1. `project-manifest.yaml` exists with `status: APPROVED`
2. `approvedat` contains the datetime of Alex's approval response — not executor processing time
3. `approvedby` exactly matches a `humandirector` entry in `humanactors`
4. An FC-4 audit log entry exists for this approval, independent of the manifest field, with `approvalstatement` containing Alex's verbatim words (minimum 5 words)
5. `RR-1-01.yaml` exists at `.framework/reviews/` with `respondedat` and `responseclassification: APPROVED` populated
6. Any corrections applied have a corresponding `CR-1-xx.yaml` and new traceability entries with `sourcetype: correction` and `supersedes` referencing the prior entry
7. No manifest field or traceability companion record was modified after `status: APPROVED` was set
8. The review record references the audit log entry and any correction records applied during the loop
