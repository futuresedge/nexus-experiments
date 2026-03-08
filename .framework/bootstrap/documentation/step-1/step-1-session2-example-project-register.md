# Part 10 — Meridian Example Register (Final State After Task 1.3)

Thirteen entries. All BLOCKERs resolved. Five non-blocking entries carried to Task 1.4 `openquestions`.

| ID | Field | Gap type | Class | Resolution status | Notes |
|---|---|---|---|---|---|
| OQ-1-01 | `techstack` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | AstroJS 5.3.0 — derivation from "latest stable" acceptance |
| OQ-1-02 | `techstack` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | Shadcn/ui 2.4.0 — derivation from "latest stable" acceptance |
| OQ-1-03 | `techstack` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | React confirmed explicit |
| OQ-1-04 | `techstack` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | pnpm confirmed explicit |
| OQ-1-05 | `deploymenttarget` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | Cloudflare Pages confirmed; linked to OQ-1-10 |
| OQ-1-06 | `devenvironment` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | Node.js 22.11.0 confirmed |
| OQ-1-07 | `appetite` | AMBIGUOUS-FORMAT | BLOCKER | RESOLVED | "Small — a few days" → enum `small` (later corrected to `medium` in Task 1.5) |
| OQ-1-08 | `integrationrequirements` | AMBIGUOUS-INCOMPLETE | WARNING | OPEN | Formspree tentative — carried to `openquestions` |
| OQ-1-09 | `existingassets` | ABSENT | INFO | OPEN | No assets in brief — carried to `openquestions` |
| OQ-1-10 | `deploymenttarget` | CONTRADICTION | BLOCKER | RESOLVED | Workers/static contradiction resolved via Q5 cascade from OQ-1-05 |
| OQ-1-11 | `null` | SCHEMA-GAP | WARNING | OPEN | Cloudflare account readiness — `schema_gap_flag: true` |
| OQ-1-12 | `null` | SCHEMA-GAP | INFO | OPEN | Maintainability/handoff requirement — `schema_gap_flag: true` |
| OQ-1-13 | `null` | SCHEMA-GAP | INFO | OPEN | Design intent descriptors — `schema_gap_flag: true` |
| OQ-1-14 | `techstack` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | `@astrojs/react` implicit dependency — created and resolved in Task 1.4 Subtask 1 |
| OQ-1-15 | `techstack` | AMBIGUOUS-INCOMPLETE | BLOCKER | RESOLVED | pnpm version — created and resolved in Task 1.4 Subtask 2 |
