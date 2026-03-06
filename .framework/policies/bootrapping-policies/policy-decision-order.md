# Framework policies decision order

## Tier 1 — Decide Before Agent Design (9 items)

These are **cross-cutting invariants and protocols** that every agent in the bootstrap phase must implement consistently. A decision made late here means revising every agent class that touches it.

| Item | Why it blocks agent design |
|---|---|
| F1 — No-invention invariant | Governs the core behaviour of every executor role — it must be a named, testable constraint before any agent is written |
| F2 — Gap classification taxonomy | Used in Steps 1, 2, 3, and 4 — agents in all four steps need the same vocabulary before their skills can be written |
| F3 — Clarification protocol | Used in Steps 1 and 2 — the format, attribution, and loop rules must be consistent across both before either step's agents are designed |
| F4 — Human approval record pattern | Used in Steps 1 and 6 — the mechanism is the same event in two places; designing both separately produces inconsistency |
| F5 — Source traceability record | Used in Steps 1 and 2 — the format and retention rule must be defined once before both steps' executors are written |
| F6 — Verifiability standard | Used in Steps 2 and 5 — the test for "is this claim verifiable" must be the same rule in both places |
| F7 — Producer/verifier separation mechanism | Underpins T5 across all steps — the *system enforcement* mechanism must exist before any reviewer role can be designed, because the design depends on what the system prevents |
| F8 — Carry-forward of open questions | The handoff protocol between steps — determines what Step 2's executor receives from Step 1 and how it reclassifies it; cannot design Step 2 cleanly without this |
| F31 — Bootstrap lifecycle state machine | The state machine underpins Steps 5 and 6 entirely — the smoke test sequence and the APPROVED/CLOSED transition both depend on states that haven't been formally defined |

***

## Tier 2 — Resolve During the Relevant Step's Agent Design (16 items)

These are **contained within one or two steps**. Resolving them is part of designing that step's agents — not a prerequisite to beginning.

| Item | Resolve when |
|---|---|
| F9 — Version ambiguity protocol | Step 1 and 2 agent design |
| F10 — Context tree governance | Step 3 agent design |
| F11 — Roster deviation governance | Step 3 agent design |
| F12 — Parallel generation constraint | Step 3 agent design |
| F13 — Individual vs set verification boundary | Step 3 agent design |
| F16 — NV score system | Step 4 agent design / skill writing |
| F18 — Composite pattern construction | Step 4 agent design / skill writing |
| F21 — Smoke test scope boundary | Step 5 agent design |
| F22 — Producer independence practical constraint | Step 5/6 agent design |
| F23 — PASS_WITH_GAPS threshold | Step 5 agent design |
| F25 — Re-run scope after FAIL | Step 5 agent design |
| F26 — Immutability mechanism | Note as a hard dependency on the Nexus server design; does not block agent class design |
| F27 — RETURNED loop limit | Step 6 agent design |
| F28 — Notification and timing | Step 6 agent design |
| F29 — Gap acknowledgement quality | Step 6 agent design |
| F30 — Delegation and substitution | Step 6 agent design |

***

## Tier 3 — Defer (6 items)

These are **delivery-phase or toolkit maintenance concerns**. They have no bearing on bootstrapping agent design.

| Item | Defer to |
|---|---|
| F14 — Design standards versioning | Framework maintenance policy |
| F15 — Stack seeding resources | Toolkit expansion process |
| F17 — Pattern lifecycle beyond seeding | Delivery phase policy |
| F19 — Cross-project pattern inheritance | Multi-project framework extension |
| F20 — Audit log continuous monitoring | Delivery phase policy |
| F24 — Smoke test versioning | Framework maintenance policy |

***

## Options for Next Steps

## Option A — Resolve Tier 1 as a Framework Cross-Cutting Policies document, then begin agent design

Produce one coherent document that settles all 9 Tier 1 items — the shared behavioural contracts that every bootstrap agent must implement. Then proceed to agent design step by step, confident the foundations are stable.

- **Pros:** Agent designs are written once correctly; no revision cycles caused by late cross-cutting decisions; the document is reusable across the delivery lifecycle too, not just bootstrapping
- **Cons:** One more document before the first agent class is written; some of the 9 items may feel easier to design in context — committing to them abstractly carries some risk of over-engineering

***

## Option B — Proceed directly to agent design, resolving Tier 1 items as first encountered

Start with Step 1's agents — the first Tier 1 item encountered (F1 and F2) gets decided in context and then carried forward.

- **Pros:** Faster first agent class; decisions are grounded in real design context
- **Cons:** Each Tier 1 decision made for Step 1 may need to be retrofitted into Steps 2–5 agents; the risk compounds — by the time Step 3 agents are designed, three or four earlier agents may need revision

***

## Option C — Resolve Tier 1 as a dedicated design session with a specific structure

Rather than a free-form policies document, treat the 9 Tier 1 items as a structured decision session: for each item, define the decision options, the recommended decision, and the output format or rule it produces. Produces tighter, more actionable outputs than a narrative policy document.

- **Pros:** Output is immediately implementable by agent designers; forces explicit decision options rather than just settled answers; produces a decision record (consistent with T4)
- **Cons:** Slightly more structured than needed if the answers are straightforward; takes longer than just stating the decisions

***

## Option D — Pivot to the delivery lifecycle policies first

Set bootstrapping aside temporarily, apply the same step-policy process to the delivery lifecycle (Zones 1–5 from the earlier work), and return to bootstrap agent design once both policy sets are complete. The Tier 1 cross-cutting items will be confirmed against both policy sets before being decided.

- **Pros:** Full picture of cross-cutting items across both lifecycles before any are decided — F2 (gap taxonomy) in delivery may have different needs than in bootstrapping; designing both before deciding produces better cross-lifecycle consistency
- **Cons:** Significantly delays getting to implementation; the bootstrapping phase is the immediate practical need; the delivery lifecycle is a larger design surface

***

## Recommendation

**Option A, with one modification.**

Resolve the 9 Tier 1 items as a single framework cross-cutting policies document **before** beginning agent design. The modification: treat it as Option C's structure inside Option A's scope — for each item, explicitly state the decision options considered, the chosen decision, and the specific rule or format it produces. This honours T4 (decisions on record with rationale) and produces something directly usable as a reference in every agent class definition you subsequently write.

The practical argument: the 9 items together can likely be resolved in one focused session. The delivery protection they provide across all six step policies is significant. And several of them — F2 (gap taxonomy), F3 (clarification protocol), F7 (producer/verifier mechanism) — will almost certainly reappear when you design the delivery lifecycle, so designing them once now with bootstrapping as the grounding context is more efficient than designing them twice.

Option D is worth flagging for later: once the bootstrap agent design is underway, a parallel track to begin the delivery lifecycle policies would allow cross-cutting items to be confirmed or revised before they're locked into agent implementations.