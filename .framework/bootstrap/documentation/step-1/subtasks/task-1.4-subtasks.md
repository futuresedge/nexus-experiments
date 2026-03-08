# Task 1.4 — Manifest Drafting

**Input:** `brief-inventory.yaml`, `open-questions-register.yaml` (all entries), `CE-1-01.yaml` (if Task 1.3 ran), manifest schema
**Output:** `project-manifest.yaml` (status: DRAFT); `project-manifest.traceability.yaml`

***

### Subtask 1 — Pre-Drafting Derivation Resolution

**Input:** `CE-1-01.yaml` queried for all `derivation_flag: true` entries
**Output:** Traceability entries for all derivation-resolved values; new register entries for any gaps discovered; version lookup performed or fallback recorded

**Skills**
- Exchange record query as first act — before field one is written
- Version lookup capability or defined fallback (CONFIRMED-UNKNOWN; register entry updated; field left empty)
- Implicit dependency detection — resolved tech stack entry checked for unlisted dependencies
- Traceability format for derivation-sourced values — sourcetype: derivationrule with lookup date, source, and authorising exchange reference

**Failure Modes**
- Pre-drafting step skipped → "latest stable" written to techstack; format rule violated; implicit dependency missed
- Version guessed without lookup → invented value in FC-1 traceability record; verification fails
- Implicit dependency not detected → `@astrojs/react` absent from manifest; Step 2 integration section incomplete

***

### Subtask 2 — Required Field Population

**Input:** Register (all RESOLVED BLOCKER entries), `brief-inventory.yaml`, traceability record (in progress)
**Output:** All required fields populated in `project-manifest.yaml`; corresponding traceability entries written field-by-field

**Skills**
- Traceability-alongside-field — two writes per field, simultaneous; not a post-population pass
- Description assembly — brief language only; every sentence traced to a named statement ID; executor voice absent
- `techstack` format rule enforcement during population — unplanned gaps create new register entries, then resolve before writing
- `humanactors` name precision — must match the value that will be used in `approvedby` at Task 1.5
- `appetite` enum mapping — register `resolutionnote` verbatim → manifest field is the enum value only

**Failure Modes**
- Traceability written after all fields → sources reconstructed from memory; multi-statement field sources partially lost; FC-1 fails
- `pnpm` written without version → format rule violation not caught if naive self-check only tests for obvious placeholders
- `humanactors` name differs from future `approvedby` value → Task 1.5 Subtask 5 validation fails

***

### Subtask 3 — Optional Field Population

**Input:** Register (WARNING and INFO entries), `brief-inventory.yaml`, traceability record (in progress)
**Output:** All optional fields populated, explicitly empty, or recorded as tentative with register cross-reference

**Skills**
- Empty field is complete — `[]` or `null` with `sourcetype: notpresentininput`
- Tentative value notation — `provider: Formspree (tentative — see OQ-1-08)`; not recorded as confirmed
- `constraints` and `outofscope` format rule — stated only; inference prohibited
- `referenceexamples` verbatim — no normalisation, no editorial description

**Failure Modes**
- Tentative value written as confirmed → Step 2 integration drafted around unconfirmed provider; correction required post-Step 2
- `constraints` populated with inferred content → FC-1 fails; no brief statement supports the entry
- Empty optional field given a default value → FC-1 fails; invented content in optional field

***

### Subtask 4 — Open Questions Field Population

**Input:** Register (all WARNING and INFO entries with `resolutionstatus: OPEN`); CONFIRMED-UNKNOWN entries
**Output:** `openquestions[]` field in manifest populated — all non-RESOLVED entries included

**Skills**
- Completeness — every non-RESOLVED register entry included; no filtering by perceived relevance
- Entry format drawn verbatim from register — field, gap, impact, classification; not rewritten
- CONFIRMED-UNKNOWN entries included as WARNING — not omitted because they were once BLOCKER

**Failure Modes**
- `schema_gap_flag` entries (field: null) omitted → Alex approves without seeing infrastructure readiness gap
- `openquestions` entries rewritten → Formspree mention lost; tentative qualifier lost; Step 2 consequence obscured

***

### Subtask 5 — Self-Check

**Input:** Complete `project-manifest.yaml`; complete traceability companion record
**Output:** All 15 items passed; `status: DRAFT` set only after all pass

**Skills**
- Self-check before `status: DRAFT` — not after
- Placeholder detection — `AstroJS 5.x` is a placeholder; `AstroJS 5.3.0` is not
- FC-1 cross-reference — field-by-field correspondence check, not a count check
- `humanactors` structural check — at least one `humandirector` entry; name matches future `approvedby`
- `approvedat` and `approvedby` absence confirmation — must not be present at DRAFT time

**Failure Modes**
- Self-check run after `status: DRAFT` set → defective manifest delivered to Alex
- FC-1 check done by count → count coincidence masks a missing traceability entry
- `approvedat` pre-populated → FC-4 violation; approval attributed to executor not human action

