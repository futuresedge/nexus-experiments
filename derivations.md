This is the right strategic pause. Let me reason through this carefully — what the derivation order would be, how it compares to what we've already built, and where the gaps are.

***

## First: What the Principles Document Is

Before we derive anything, the document needs one thing we haven't stated yet: a **compliance test**. Every downstream policy, design document, and template should be able to answer:

> *"Which principles does this implement, and which principles would be violated if this were removed?"*

If a document can't answer that, it is either aspirational or orphaned. This gives us a way to audit everything we've already built.

***

## The Derivation Order From First Principles

Starting only with the 17 principles, here is the order in which things must be built — and why each step is a prerequisite for the next.

***

### Derivation Step 1 — The Grammar and Schema
**Principles driving this:** P3, P4, P5, P12

Before a single tool is built, you need the naming grammar and audit schema, because:
- P3 says violations must be structurally impossible → tool names must encode capability and scope unambiguously
- P4 says consequences belong inside tools → tools need a schema to write to
- P5 says every action is recorded → the audit schema must be designed for completeness *before* tools are written, not retrofitted
- P12 says conventions are load-bearing → the grammar must precede any implementation

**What we have:** Tool Grammar v0.1 ✅ — but it needs to be v0.2 to satisfy P5, which would have been caught at design time if the principles had existed first. The `read_` and `search_` audit gap is exactly the kind of defect P5 is designed to prevent upstream.

**What would change:** The grammar document would explicitly reference P3, P4, P5, and P12. Any designer reading it would know *which principle* each rule serves — making the grammar not just a reference but a traceable design decision.

***

### Derivation Step 2 — The Knowledge Structures
**Principles driving this:** P7, P14, P17

Before defining any agent, you need to know how knowledge flows through the system, because:
- P7 says context must be minimum and sufficient → you need a *mechanism* for generating context (the knowledge base and context card architecture), not just a template
- P14 says the framework learns through structured retrospectives, not longer specs → the Pattern Library schema needs to exist before any pattern is recorded in it
- P17 says trust is progressive → the NV scoring system needs a place to store the evidence that moves a pattern from NV=2 to NV=0

**What we have:** Context Curation Policy ✅, Pattern Library concept ✅ — but the Pattern Library schema is not yet defined. We know what it stores conceptually; we haven't defined its fields. This is a gap that will block Zone 0 work because the FOA's first action is `search_knowledge_base`, and that tool needs a schema to query.

**What would change:** The context card template and Pattern Library schema would be designed together as a pair in this step, before any agent specs are written. Right now they exist as separate concerns.

***

### Derivation Step 3 — The Agent Design Standard
**Principles driving this:** P7, P8, P9, P15, P16

With grammar, schema, and knowledge structures in place, you can define what an agent *is*:
- P15 (one agent, one artefact) → the Base Agent Template's single `WRITES:` field is not arbitrary; it is a structural enforcement of this principle
- P8 (separate definition/execution/verification) → the three TYPE classes (ORCHESTRATOR, EXECUTOR, COMPRESSION) map to these roles; REVIEWER field is a structural enforcement
- P9 (fail loudly) → `raise_uncertainty` is a universal tool by principle, not by convention; the Base Agent Template must require it
- P7 (minimum context) → `get_context_card` is the mandatory first call, not a recommended practice
- P16 (observer never controls) → agent templates must declare what they observe separately from what they control — this maps to the READS/NEVER distinction

**What we have:** Base Agent Template v0.2 ✅ — but it doesn't yet reference which principles each required field implements. The `REVIEWER:` field exists but isn't explicitly traced to P8.

**What would change:** Every required field in the Base Agent Template would have a principle reference. An agent spec reviewer checking a template would be checking *principle compliance*, not just format compliance.

***

### Derivation Step 4 — The Work Lifecycle
**Principles driving this:** P6, P8, P10, P11

With agents defined, you can define how work flows:
- P6 (evidence not assertion) → the proof template / QA review structure; literal output required
- P8 (separate definition/execution/verification) → the three-role pattern is a lifecycle requirement, not an agent design preference
- P10 (irreversible decisions need human authority) → human gates are placed at state transitions that cannot be undone
- P11 (proportional oversight) → QA tier assignment is not about strictness; it is about calibrating oversight to blast radius and novelty

**What we have:** Context Curation Policy ✅, Zone policies ✅, QA tier system in Agent Creation Policy ✅ — but these were derived independently rather than from explicit principle lineage.

**What would change:** The zone policies would explicitly map their human gates to P10 and their QA tiers to P11. A designer proposing a new zone gate would have to justify it against P10 — is this genuinely irreversible? — rather than just adding gates for safety.

***

### Derivation Step 5 — The Governance Policies
**Principles driving this:** All of the above, plus P13 and P17

With the lifecycle defined, you can write policies for how the framework governs itself:
- Agent Creation Policy (Zone 0) → implements P8 (no self-review), P11 (proportional oversight), P17 (progressive trust via NV scoring)
- Context Curation Policy → implements P7, P8 (curator ≠ reviewer)
- Uncertainty Protocol → implements P9

**What we have:** All three ✅ — these are in good shape. The Agent Creation Policy v0.2 is the most mature.

**What would change:** Each policy would open with a **Principles Declaration** — listing which principles it implements and which it would violate if removed. This creates the traceability the principles document needs to have teeth.

***

### Derivation Step 6 — Infrastructure Build
**Principles driving this:** P13

Only now do you build:
- P13 says prove before building — each infrastructure phase needs a falsifiable hypothesis, stated acceptance criteria, and literal evidence

**What we have:** Nexus Exp-01 ✅ — this was done correctly. Exp-01 was hypothesis-driven. The gap is that Exp-01 predated the principles, so the hypotheses weren't explicitly traced to principles. H1–H5 all implement P3, P4, or P5.

**What would change:** Experiment hypothesis cards would reference the principles being tested. H5 (chain of custody) was implicitly testing P5, but never stated that way. Naming it would have caught the `read_` audit gap before the test, not during it.

***

## The Compliance Audit: What We Have vs. What the Principles Require

| Principle | Has Implementation? | Gap |
|---|---|---|
| P1 — Coordination Cost | ✅ Nexus model, framework purpose | None |
| P2 — Asymmetric Cost | ✅ QA tiers, proof templates | Not stated as justification anywhere explicitly |
| P3 — Structure Over Instruction | ✅ OCAP, Tool Grammar | `NEVER` lists still exist alongside OCAP — P3 says tool absence supersedes them; docs don't make this explicit |
| P4 — Consequences Inside Tools | ✅ Compound tools, Grammar Rule 6 | None |
| P5 — Every Action Recorded | ⚠️ Partial | `read_` and `search_` audit gap — being fixed, but the gap existed because P5 wasn't upstream |
| P6 — Evidence Not Assertion | ✅ Proof templates, literal output | None |
| P7 — Minimum Sufficient Context | ✅ Context Curation Policy | Context card template fields not yet locked; Pattern Library schema not yet defined |
| P8 — Separate Definition/Execution/Verification | ✅ Three-role pattern, Agent Pair | Not explicitly referenced in Agent Creation Policy as the basis for the Agent Pair invariant |
| P9 — Fail Loudly | ✅ `raise_uncertainty`, pre-flight | Pre-flight split across 3 tools; not yet explicit that bypassing it is a P9 violation |
| P10 — Irreversible = Human Authority | ✅ FO gates | FO visibility layer not yet designed (raised today) — humans can't exercise authority they can't observe |
| P11 — Proportional Oversight | ✅ NV/BR scoring | None |
| P12 — Conventions Are Load-Bearing | ✅ Tool Grammar | Not stated as a principle anywhere; treated as style guidance in some contexts |
| P13 — Prove Before Building | ✅ Experiment methodology | Hypothesis cards don't reference which principles are being tested |
| P14 — Framework Learns | ✅ Pattern Library concept | Pattern Library schema not yet defined; no formal retrospective-to-entry process |
| P15 — One Agent, One Artefact | ✅ Single WRITES field | Never stated as a principle — currently just a template rule with no stated rationale |
| P16 — Observer Never Controls | ✅ Webhook architecture | Not stated as a principle — the decision exists but only as a rationale in NexusDecisionsRationale.md |
| P17 — Trust Is Progressive | ✅ NV scoring | Pattern Library has no mechanism yet to record evidence that reduces NV over time |

***

## The Next Steps From Here

Given the audit above, here is the ordered work — treating the principles document as the upstream source:

**1. Finalise and store the principles document** as the first entry in the framework manifest. Version it (v1.0). It is the only document in the framework that has no principle parent — it *is* the parent.

**2. Update the Tool Grammar to v0.2** — fix the `read_` and `search_` audit entries, update Rule 5, and add principle references to each verb definition. This is the most urgent fix because it affects the Nexus server implementation.

**3. Define the Pattern Library schema** — this is currently the largest structural gap. The FOA cannot begin Zone 0 work until `search_knowledge_base` has something to query. Even an empty but correctly structured Pattern Library is better than none. Fields needed: `entry_id`, `pattern_name`, `nv_score_at_first_run`, `current_nv_score`, `evidence_sessions[]`, `agent_classes_affected[]`, `zone`, `tags`, `summary`, `full_content_path`.

**4. Lock the context card template** — the format needs to be formally defined so `get_context_card` has a schema to return. This unblocks the FOA's context card (the last item on the Zone 0 readiness checklist).

**5. Add Principles Declarations to each existing policy** — a one-page preamble to each policy document listing which principles it implements. This is low effort but high value: it makes the corpus traceable and makes violations nameable.

**6. Revisit the bootstrapping checklist** through P13 — the checklist is currently a list of things that must exist. Under P13, each item on the checklist needs an acceptance criterion, not just a checkbox. "Pattern Library schema defined" needs a test: what does a passing schema look like? This turns the readiness checklist into a proof template for the bootstrapping phase itself.

**7. Design the FO observation layer** — P10 says irreversible decisions require human authority, but authority requires visibility. The FO currently has no designed mechanism to observe stream events outside of an agent interface. This is the gap raised earlier today. It is a P10 gap, not just an architecture gap — and naming it as a P10 gap makes its priority clear.

The first three are blockers for bootstrapping. The last four are needed before the first real project can run cleanly against the principles.