# UQ-03 Resolution Recommendation

**The problem stated precisely:**

FC-3 governs clarification — it resolves missing declared information. Its explicit scope statement: *"the clarification protocol resolves missing declared information, not undecided information."*  When a Task 1.3 clarification response returns `DECISION-REQUIRED`, the executor has no defined path. The process blocks with no mechanism to unblock it. 

This is a structural gap, not an edge case. Any project where Alex hasn't yet decided a technically consequential choice — form handler provider, deployment tier, authentication approach — will hit this gap on the first BLOCKER clarification.

***

## The Core Distinction

Before designing the mechanism, the distinction must be precise:

| | FC-3 Clarification | UQ-03 (DECISION-REQUIRED) |
|---|---|---|
| **Cause** | Alex has the information but didn't include it | Alex doesn't yet have an answer — the choice is unmade |
| **Example** | "What Node version are you running?" | "Have you decided between Formspree and a custom handler?" |
| **Executor's role** | Retrieve existing knowledge | Support a decision the human must make |
| **Block reason** | Missing data | Unmade decision |
| **Unblock condition** | Alex provides the value | Alex makes and states the decision |

These are different events. Extending FC-3 to cover the second case would directly contradict FC-3's own scope statement and conflate two distinct executor behaviours. The correct solution is a new, separate mechanism. 

***

## Recommendation: FC-9 Human Decision Support Protocol

### Why FC-9 and not FC-3 extended

FC-3's explicit scope exclusion is not incidental phrasing — it is the policy's integrity boundary.  Extending FC-3 to include decisions would require removing that boundary, after which FC-3 would need to specify when to clarify versus when to support — which recreates the same design problem inside FC-3. A new protocol is cleaner and consistent with how FC-4 (approval) was kept separate from FC-3 (clarification) despite both being human interactions. 

***

## FC-9 — Human Decision Support Protocol

**Version:** 0.1 Draft
**Scope:** Bootstrap phase. Applies wherever a BLOCKER register entry returns `resolutionstatus: DECISION-REQUIRED` from a clarification response.

***

### Context

When a BLOCKER gap is presented via FC-3 and Alex responds that the information does not yet exist because a decision is unmade, FC-3's resolution loop cannot close. FC-3 resolves *missing declared information.* An unmade decision is not missing information — it is an unexercised judgment. The executor's role shifts: from retrieval to support.

***

### What FC-9 does

FC-9 governs the executor's behaviour when a BLOCKER register entry has `resolutionstatus: DECISION-REQUIRED`. It defines:

- What the executor presents to Alex to support the decision
- The artefact produced (Decision Request record)
- The process state entered
- The unblock condition and return path
- What the executor must not do

***

### What the executor presents

When `DECISION-REQUIRED` is confirmed, the executor produces a structured decision support package containing four elements — no more, no fewer:

**1. Field and impact statement** — names the manifest field and why it is blocked:

> *"`integrationrequirements.provider` — the form handler provider must be confirmed before the Step 2 integration contract can be written. Without it, the Step 2 executor cannot specify the submission endpoint, the CORS configuration, or the environment variable schema."*

**2. Options** — the available choices, drawn only from the executor's knowledge base or information already in the brief. No invented options. Each option includes a one-sentence description and a one-sentence implication:

> *"Option A: Formspree — hosted form handler; requires a Formspree account and a POST endpoint in the form's action attribute. Implication: no server-side logic required; the integration is a single configuration value.*
> Option B: Custom server-side handler — requires a server-rendered route or a serverless function. Implication: contradicts the `fullyStatic` constraint declared in the manifest; would require constraint revision.*
> Option C: Defer this decision — proceed with the form handler entry marked CONFIRMED-UNKNOWN. Implication: the Step 2 integration section cannot be drafted; the decision must be made before Step 2 begins."*

**3. Decision instruction** — names exactly what response constitutes a usable decision:

> *"To unblock this: state which option you are selecting, or provide a different option not listed above. If you choose to defer (Option C), confirm explicitly — the field will be left empty and flagged as CONFIRMED-UNKNOWN."*

**4. No recommendation** — the executor does not recommend an option. This is the boundary between decision support and scope-setting. Providing a recommendation is a scope-setting act — it introduces executor preference into a human-owner judgment call. 

***

### The Decision Request record

A new artefact type — DR series. Distinct from CE (clarification exchange) and RR (review record).

Filed at: `.framework/decisions/DR-{step}-{seq}.yaml`

```yaml
decisionrequestid: DR-1-01
step: 1
register_ref: OQ-1-08
field: integrationrequirements.provider
decisionrequired: >
  Which form handler provider will be used?
options:
  - optionid: A
    description: "Formspree — hosted form handler"
    implication: "No server-side logic required; single configuration value"
  - optionid: B
    description: "Custom server-side handler"
    implication: "Contradicts fullyStatic constraint; requires constraint revision"
  - optionid: C
    description: "Defer — proceed with CONFIRMED-UNKNOWN"
    implication: "Step 2 integration section cannot be drafted; decision required before Step 2"
requestedat: "ISO 8601"
respondedAt: null
selecteddecision: null          # Alex's chosen option ID or free-text description
decisionstatement: null         # verbatim from Alex's response
resolvedvalue: null             # the field value this decision produces
resolvedoption: null            # A | B | C | OTHER
resolutionstatus: AWAITING-DECISION
```

***

### Process state

When a DR record is created:

- The register entry for the affected BLOCKER gap is updated: `resolutionstatus: AWAITING-DECISION`
- The step enters `AWAITING-DECISION` state for this entry
- No other BLOCKER gaps are blocked by this state — other entries continue through FC-3 in parallel
- The step's final blocking condition (no remaining OPEN BLOCKER entries) cannot be satisfied while any entry is in `AWAITING-DECISION`

The process **does not** downgrade the entry, proceed past it, or set a timeout.  L2 applies: the step was blocked by an unmade decision that belongs to Alex. The human must cross this threshold consciously. 

***

### Unblock condition

Alex responds with a decision. The response is classified identically to a FC-3 response — one of three outcomes:

| Response | Classification | Action |
|---|---|---|
| Alex names an option or provides a specific value | `DECISION-MADE` | DR record closed; register entry updated to `RESOLVED` with `resolvedvalue` populated; FC-3 resumes for this entry |
| Alex explicitly defers (selects Option C or equivalent) | `DEFERRED` | DR record closed; register entry updated to `CONFIRMED-UNKNOWN`; gap downgraded from BLOCKER per FC-2 downgrade rules; Step proceeds without the value |
| Alex's response is ambiguous | `UNCLEAR` | Follow-up question per P-Subtask3-01; DR record `respondedAt` not set until a classifiable response arrives |

Note on `DEFERRED`: explicit deferral by Alex is materially different from an unresolved DECISION-REQUIRED. When Alex says *"I'll decide later,"* that is a conscious choice to proceed with a gap — which satisfies L2.  The gap becomes `CONFIRMED-UNKNOWN` with Alex's explicit attribution. A process that never received a response is still blocked. 

***

### What FC-9 does not govern

- **Design preferences** — FC-9 presents options to support a decision; it does not gather preferences about things Alex has already decided
- **Scope additions** — if Alex's decision reveals new scope not in the brief (e.g. *"I want SSR now"*), that is a scope change, not a decision. It requires a correction path, not an FC-9 resolution
- **Multi-step deferral** — if Alex defers a decision at Step 1, FC-9 does not guarantee the decision will be re-requested at Step 2. The carry-forward protocol (FC-8) governs re-classification at each step; if the gap is still BLOCKER in Step 2's context, FC-9 is invoked again at Step 2

***

### The executor boundary — what it must not do

- Must not recommend an option. Presenting options is support; recommending is scope-setting.
- Must not invent options not grounded in the knowledge base or the brief.
- Must not proceed past a `AWAITING-DECISION` entry by treating silence as implicit deferral.
- Must not create a DR record for a gap that FC-3 could resolve — if Alex simply hasn't provided a value they clearly know, FC-3 is the correct mechanism. FC-9 is only triggered when Alex has explicitly stated the decision is unmade.

***

### Trigger condition — FC-9 vs FC-3

The boundary must be explicit. One test, one question:

> *"Does Alex have this information available right now, and would stating it resolve the gap?"*

- **YES → FC-3.** The gap is missing declared information. Ask.
- **NO → FC-9.** The gap is an unmade decision. Support.

The trigger is Alex's own response, not the executor's prior classification. FC-3 runs first. If the FC-3 response indicates `DECISION-REQUIRED`, FC-9 is then invoked. FC-9 is never invoked before FC-3 is attempted.

***

### Policy improvements produced

| ID | Description | Affects |
|---|---|---|
| **FC-9 (new)** | Human Decision Support Protocol — governing the DECISION-REQUIRED path | FC-3, FC-8, Task 1.3 policy |
| **FC-3 update** | Add a cross-reference to FC-9 at the DECISION-REQUIRED classification point. The current FC-3 statement *"does not cover undecided information"* should become: *"when undecided information is identified, FC-9 Human Decision Support Protocol is invoked."*   | FC-3 |
| **FC-2 update** | Add `AWAITING-DECISION` as a valid intermediate `resolutionstatus` for BLOCKER entries — distinct from `OPEN`, `RESOLVED`, `CONFIRMED-UNKNOWN`, and `ACCEPTED-AS-KNOWN-GAP`. | FC-2, register schema |
| **FC-8 update** | Carry-forward rules must handle `AWAITING-DECISION` explicitly: an entry in this state at Step 1 handoff is carried to Step 2 with status preserved; Step 2 must assess whether it is still BLOCKER in its own context before deciding whether to invoke FC-9 again or reclassify. | FC-8 |
| **Register schema update** | Add `decisionrequestref: DR-x-xx` as an optional field — populated when `resolutionstatus: AWAITING-DECISION`. Links the register entry to its DR record without embedding DR content in the register. | Register schema |

***

## Done When — UQ-03 is resolved

UQ-03 is closed when all five conditions are simultaneously true:

1. FC-9 exists as a named, versioned policy document with a stated scope, trigger condition, and executor boundary
2. FC-3 contains an explicit cross-reference to FC-9 at the `DECISION-REQUIRED` classification point
3. FC-2 includes `AWAITING-DECISION` as a valid intermediate `resolutionstatus` with a defined transition rule
4. The register schema includes `decisionrequestref` as an optional field
5. The DR artefact schema is defined with all required fields