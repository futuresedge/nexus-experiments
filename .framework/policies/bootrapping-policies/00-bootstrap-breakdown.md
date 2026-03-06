# Bootstrap breakdown

Designing the bootstrap phase with first principles.

***

## The Analogy

When a human software project receives a brief, a well-run inception phase does exactly five things before any building begins: it agrees on *what* is being built, specifies *where* it will be built, defines *who* does *what*, establishes *shared knowledge*, and proves the whole system *actually works*. Only then does a responsible human say: we are ready.

Bootstrapping in this framework is that inception phase, made rigorous.

***

## 1. Definition of Done

Per **L6** — definition of done is written first, by someone other than the party that will declare it complete.

Bootstrapping is done when **all six conditions are simultaneously true**:

- **Intent is agreed.** There is a formally structured, human-approved record of what this project is — scope, constraints, actors, appetite, and everything that is explicitly out of scope. The record was reviewed by the human who provided the brief and confirmed to accurately represent their intent without invention or loss.

- **Environment is specified and verified.** There is a complete specification of every environmental dependency for this project. Every statement in the specification has been checked against reality — not just written, but confirmed — by a party other than the one who wrote it.

- **Every required role is defined and verified.** There is a complete, project-specific definition for every role needed to perform, review, and govern work on this project. Each definition has been independently checked against the framework's design standards. There are no gaps, no scope overlaps between roles, and no role that exists in generic form only.

- **The shared knowledge base is seeded.** There is a minimum viable set of verified, applicable patterns for the declared approach. The minimum is five. Every pattern has been independently reviewed. At least one pattern directly addresses how to verify that a unit of work is complete in this project's approach.

- **The system has been proven end-to-end.** A minimal unit of work has been run through the complete process — from creation through to a verified completion state. Every infrastructure component has been exercised, not just checked for existence. The test produced an audit record. The test stopped before any real delivery work began.

- **A responsible human has explicitly confirmed readiness.** The person accountable for this project has reviewed the evidence of the above and made a conscious, timestamped decision to proceed. This decision is on record. Per **L2**, it is an irreversible threshold, and a human must cross it deliberately.

Bootstrapping is **not** done if any of the following are true:
- The project record has not been approved by `human:director`
- Any environmental claim has not been verified against the actual environment
- Any required role definition is missing, incomplete, or has not passed independent review
- Fewer than five patterns have been reviewed and promoted
- The end-to-end test was not run, or ran and produced a failure
- `human:director` has not explicitly confirmed readiness

***

## 2. Required Inputs

These are the raw materials that must exist before bootstrapping begins. They come from `human:director`. No step can begin without the hard blockers being present or resolvable.

### Hard blockers

| Input | What it provides | Why it blocks |
|---|---|---|
| Project name | Unique identifier | Every downstream document is named from this |
| Project description | 2–4 sentences of intent | Defines scope; without it, nothing else can be scoped |
| Approach / technology declaration | Named technologies + versions where known | Drives environment specification and knowledge base seeding |
| Deployment target | Where the output runs, how it's accessed | Required for environment specification to be complete |
| Development environment | Local setup — OS, runtime, tooling | Required to verify the environment actually works |
| Human actors and roles | Named humans + decision authority | Required to know who approves what; no governance without this |
| Appetite declaration | Rough size signal | Required to right-size the project record; prevents scope from being undefined |

### Enriching inputs (not blockers, but raise output quality)

| Input | What it provides |
|---|---|
| Known constraints | Explicit limits that rule out approaches before work begins |
| Existing assets | Reduces invention; grounds early decisions in real material |
| Reference examples | Clarifies intent faster than prose |
| Integration requirements | Prevents environment specification gaps for external dependencies |
| Explicit out-of-scope declarations | Reduces the burden of scope-checking during delivery |

***

## 3. Steps

The steps are in dependency order. No step begins until the preceding step's output is verified and accepted. The human gates are **not** steps — they are the acceptance conditions of the steps that produce something requiring human judgment.

***

### Step 1 — Project Intent Capture

[Step 1 policy](./01-step-one-policy.md)

**Question:** Is the project intent clear, complete, and consistent enough to structure?

**Input:** The `human:director` brief in whatever form it was provided — email, conversation, document, spoken notes.

**Output:** A structured project record containing: project identity, description, declared approach, deployment target, development environment, human actors with their decision authority, appetite, any explicit out-of-scope declarations, and a list of any brief elements that were ambiguous, missing, or contradictory.

**Done when:** `human:director` has reviewed the structured record and confirmed it accurately represents their intent. Nothing has been invented to fill gaps — gaps are surfaced as open questions. Contradictions in the brief are surfaced before the record is written, not silently resolved. The record is in `APPROVED` status.

**Principle expression:** L5 — understand the problem before designing; T5 — the person who provided the brief reviews the structured record, not the person who structured it; L2 — the scope of the project is a human decision.

***

### Step 2 — Environment Specification

[Step 2 policy](./02-step-two-policy.md)

**Question:** What must be true about the environment for work to succeed?

**Input:** The approved project record — specifically the approach declaration and deployment target.

**Output:** A complete environment specification. Every environmental dependency is named. Every configuration parameter is stated. For every claim, a verification method is defined — how would you confirm this is true in the actual environment? The specification also names any constraints that rule out certain approaches.

**Done when:** A party other than the one who wrote the specification has read every claim and confirmed: the specification is internally consistent, the verification method for each claim is genuinely testable, and no field has been left unresolved without a documented reason. The specification is accepted before role configuration begins.

**Principle expression:** T1 — checked not claimed; T2 — the specification must define how each claim is proven, not just assert it; T4 — the review verdict and its evidence are on record.

***

### Step 3 — Role Configuration

**Question:** Does every role required to perform, review, and govern work on this project have a complete, project-specific definition?

**Input:** The approved project record, the accepted environment specification, and the toolkit's base role definitions.

**Output:** A complete set of project-specific role definitions — one for each role in the required roster. Each definition is configured for this project: file paths reference this project's structure, knowledge references apply to this project's approach, and capability scope is bounded to this role's work. Generic base definitions are not sufficient — they must be instantiated.

**Done when:** Every definition has been independently checked against the framework's design standards. The complete set has been reviewed for: no two roles claiming write authority over the same output, no output type in the project's required work without a designated writer, no role definition that references paths or knowledge that does not exist in this project. Any definition that fails this review is returned and corrected before the set is accepted.

**Principle expression:** T3 — authority is structural and derives from configuration held; T5 — role definitions are reviewed by someone other than the author; T6 — the set is verified as a whole, not only as individual definitions; P3 — a misconfigured role is blocked by design, not by policy.

***

### Step 4 — Knowledge Base Seeding

**Question:** Does the shared knowledge base contain enough verified, applicable patterns to give the first unit of delivery work meaningful starting context?

**Input:** The accepted environment specification and the approved project record.

**Output:** A minimum viable set of verified, applicable patterns for the declared approach. Each pattern is structured: a problem it solves, the approach, evidence that the approach works, and the conditions under which it applies. At minimum five patterns. At least one pattern addresses how to verify that a unit of work is complete in this project's approach — this is the most load-bearing pattern in the initial set.

**Done when:** Every pattern has been independently reviewed against the following criteria: is the problem clearly stated, is the approach genuinely reusable across more than one task, is the evidence plausible (not invented), are the applicability conditions specific enough to rule out incorrect use? Patterns that are too vague, too narrow, or lack evidence are returned before the minimum count is assessed.

**Principle expression:** L3 — the knowledge base is the system's memory; L4 — shared wisdom is stored centrally and available to all future work; T1 — patterns are reviewed before promotion, not just authored.

***

### Step 5 — End-to-End Verification

**Question:** Does the system actually work — not in theory, but in practice?

**Input:** All prior outputs (project record, environment specification, role definitions, knowledge base) plus the live system infrastructure.

**Output:** A bootstrap report. The report contains: a structured pass/fail assessment of every output from Steps 1–4 with evidence for each item, results from the smoke test (see below), a verdict of PASS, PASS WITH GAPS, or FAIL, and a gap list if any items did not fully pass.

**The smoke test:** A minimal unit of work is created and run through the complete process. The test exercises: work creation, specification, knowledge base consultation, execution, independent review, and completion. The test explicitly stops before any real delivery work — it exists only to prove the system functions. At each stage, the audit log must record the action. The test is not complete until a completion state has been reached and confirmed. The test task is cancelled after the test completes — it is not real work.

**Done when:** Every document check is evidenced (not asserted). The smoke test produced an audit record at every step. The audit log has no gaps. Every infrastructure component was exercised. The report clearly distinguishes "file exists" from "component is functional." A FAIL verdict is issued if any of the following are true: a required document is missing, the smoke test failed at any step, the audit log has a gap, or the pattern count is below minimum. Per **T5**, the party that runs the verification is not the party that produced any of the outputs being verified.

**Principle expression:** T2 — proof over pretty outputs; PF2 — test small before going big; T4 — all audit entries are immutable and attributed; T1 — the bootstrap report is evidence, not assertion.

***

### Step 6 — Human Readiness Confirmation

**Question:** Does the person accountable for this project agree that everything is in place to begin building?

**Input:** The bootstrap report.

**Output:** An explicit, timestamped, attributed human decision: `APPROVED` or `RETURNED WITH GAPS`.

**Done when:** `human:director` has reviewed the bootstrap report — not the individual outputs, but the synthesised evidence of readiness — and has made a deliberate decision to proceed or to return specific items for remediation. An APPROVED decision is the irreversible threshold between bootstrapping and delivery. It is not automatic. It is not delegatable.

**Principle expression:** L2 — humans decide on one-way moves; T4 — the decision is on record; L6 — done is confirmed by the party who authorised the work to begin, not by the system that prepared it.