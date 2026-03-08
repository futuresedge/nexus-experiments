# Part 4 — New Artefact Types Confirmed This Session

Two artefact types not previously defined:

| Artefact | Series | Purpose | Distinct from |
|---|---|---|---|
| Review Record | `RR-{step}-{seq}` | FC-4 Tier 1 approval record — documents the human review exchange: what was presented, when, what the response was, and what audit log entry it produced | CE records (those are FC-3 gap resolution, not approval) |
| Correction Record | `CR-{step}-{seq}` | Documents each RETURNED correction: field, previous value, corrected value, basis, and whether it is a value correction or scope addition | Not embedded in the review record — separate artefact so corrections are independently queryable |

The distinction between CE, RR, and CR series must be made explicit in the framework's document taxonomy (FC-8 / context tree).

***