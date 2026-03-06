# Step 4 Policy: Knowledge Base Seeding

**Version:** 0.1 — Draft
**Depends on:** Step 1 `project-manifest.md` in `APPROVED` status; Step 2 `environment-contract.md` in `ACCEPTED` status
**Note on Step 3 dependency:** Step 4 does not depend on Step 3's completion. Steps 3 and 4 may run concurrently once Steps 1 and 2 are done.
**Blocks:** Step 5 (End-to-End Verification) cannot begin until this step's minimum viable seed set is accepted

***

## Overview

Step 4 answers one question: *Does the shared knowledge base contain enough verified, applicable patterns to give the first unit of delivery work meaningful starting context?*

When delivery begins, roles receive a context card before each task. That card includes relevant patterns from the knowledge base — reusable solutions to known problems in this project's approach. If the knowledge base is empty, every context card is empty, and every role starts every task with no inherited knowledge. That is the most expensive possible starting point.

Seeding is not invention. Patterns do not come from imagining what might work. They come from documented knowledge of the declared tech stack: established conventions, configuration approaches with known outcomes, integration patterns with evidence of effectiveness. The knowledge exists — this step finds it, structures it, and verifies it before adding it to the knowledge base.

Every pattern must earn its place. A pattern that is too vague gives roles false confidence — they apply it to situations it doesn't suit. A pattern that is too narrow is not reusable — it describes one task, not a class of tasks. A pattern with invented evidence is worse than no pattern — it propagates incorrect knowledge into every task that selects it.

The knowledge base produced here is not final. It is the minimum viable starting point. Patterns will be added, refined, and deprecated throughout the project as delivery work produces evidence. But it cannot be empty when delivery begins, and it cannot contain unverified entries.

The single most critical pattern in the seed set is the **verification pattern**: how to prove, for this specific stack, that a unit of work is complete. This pattern is the foundation of the proof system for every task this project will execute. If this pattern is missing, the proof system has no project-specific grounding.

***

## Inputs

### Summary

| Input | Source | Requirement | If Absent |
|---|---|---|---|
| `project-manifest.md` in `APPROVED` status | Step 1 output | **REQUIRED** | Hard blocker — no project scope to seed against |
| `environment-contract.md` in `ACCEPTED` status | Step 2 output | **REQUIRED** | Hard blocker — no verified stack to draw patterns from |
| Pattern schema | Toolkit | **REQUIRED** | No format to structure patterns into; available by default |
| Stack seeding resources | Toolkit | **REQUIRED** | No evidenced starting point for pattern identification; see F15 |
| Pattern library (initially empty) | Project / Nexus server | **REQUIRED** | No storage target for produced patterns |

### Detailed Input Specifications

#### `project-manifest.md`

| Criterion | Requirement |
|---|---|
| **Status** | Must be `APPROVED` |
| **Fields used** | `tech_stack`, `constraints`, `out_of_scope`, `appetite` |
| **Scope signal** | `appetite` and `out_of_scope` inform the scope of seeding — a small appetite project does not need patterns for capabilities it will never use; `out_of_scope` declarations rule out entire pattern domains |

#### `environment-contract.md`

| Criterion | Requirement |
|---|---|
| **Status** | Must be `ACCEPTED` |
| **Fields used** | `framework`, `styling`, `deployment`, `services`, `constraints`, `performance`, `verification` |
| **Primary use** | The contract is the verified source of truth about the stack — patterns must be consistent with the contract's declared configuration, not with the technology in the abstract. A pattern describing `output: server` configuration is not valid for a project whose contract declares `output_mode: static` |
| **Verification section** | The contract's `verification.local_check` and `verification.deployed_check` entries inform how the verification meta-pattern should be written for this project |

#### Stack seeding resources

| Criterion | Requirement |
|---|---|
| **Format** | Structured knowledge resources in the toolkit, organised by technology. One resource per supported technology or technology combination. |
| **Coverage** | A seeding resource must exist for every technology declared in `tech_stack`. If no resource exists for a declared technology, this is a `BLOCKING` gap — patterns for that technology cannot be produced from invention |
| **Currency** | Resources must correspond to the version declared in the environment contract where versions are known. A resource for AstroJS 3.x is not valid input for a project declaring AstroJS 5.x if the patterns differ between versions |
| **Evidence basis** | Every entry in a seeding resource must reference an evidence source: official documentation, prior project results, known outcomes. Entries without an evidence basis are not valid seeding inputs |

#### Pattern library

| Criterion | Requirement |
|---|---|
| **State at input** | Empty for a new project — this step populates it from zero |
| **Access** | Write access to add `CANDIDATE` entries; the promotion decision (to `PROVISIONAL`) is made in Task 4.4 |
| **Schema enforcement** | The library must reject entries that do not conform to the pattern schema — conformance is not optional |

***

## Outputs

### Summary

| Output | Requirement | If Absent or Incomplete |
|---|---|---|
| ≥ 5 patterns in `PROVISIONAL` status | **REQUIRED** | BLOCKER — minimum viable seed set not met |
| At least 1 verification meta-pattern in `PROVISIONAL` status | **REQUIRED** | BLOCKER — proof system has no project-specific grounding |
| Every `PROVISIONAL` pattern independently reviewed and accepted | **REQUIRED** | BLOCKER — unreviewed patterns may propagate incorrect knowledge |
| Domain coverage map | **REQUIRED** | WARNING — gaps in coverage are not visible to Step 5 without it |
| Review record for each pattern | **REQUIRED** | BLOCKER — no evidence the no-invention and evidence-plausibility constraints were met |

### Detailed Output Specifications

#### Pattern entry — schema

Every pattern added to the knowledge base must conform to this schema. Every field marked REQUIRED must be non-empty. Fields marked OPTIONAL must be present even if empty.

| Field | Type | Requirement | Format rule |
|---|---|---|---|
| `pattern_id` | String | **REQUIRED** | Kebab-case; unique within the knowledge base; derived from the problem domain and technology, e.g., `astro-static-output-config` |
| `pattern_name` | String | **REQUIRED** | Human-readable; describes what the pattern does, not the problem it solves; e.g., `AstroJS Static Output Configuration for Netlify` |
| `status` | Enum | **REQUIRED** | `CANDIDATE` on creation; `PROVISIONAL` after review and promotion; `ACTIVE` after evidence from live delivery work (not set in this step); `DEPRECATED` when superseded |
| `created` | ISO 8601 datetime | **REQUIRED** | Set at creation; never modified |
| `last_reviewed` | ISO 8601 datetime | **REQUIRED** | Set when review verdict is recorded; updated on each subsequent review |
| `problem` | String | **REQUIRED** | 1–2 sentences. What specific problem does this pattern solve? Must be concrete enough that a role can determine whether its current task has this problem. Must not be so broad that it applies to everything. |
| `approach` | String | **REQUIRED** | The solution. What to do. Specific enough to be actionable without requiring judgment to interpret. Not a principle ("write modular code") — a practice ("place component files in the same directory as the page that uses them, not in a shared `/components` directory, unless used by more than two pages"). |
| `evidence` | String | **REQUIRED** | Why does this work? Must reference a traceable source: official documentation with a specific claim, prior project results with an outcome, a known behaviour of the technology. "It's good practice" is not evidence. "AstroJS documentation specifies that `output: static` is required for Netlify's static adapter to function correctly" is evidence. |
| `applies_when` | List of strings | **REQUIRED** | Conditions under which this pattern is appropriate. At least one entry. Each condition is a specific, checkable statement — not a vague category. |
| `does_not_apply_when` | List of strings | **REQUIRED** | Conditions under which this pattern should not be used. At least one entry. If a pattern applies everywhere without exception, it is too broad. |
| `stack_tags` | List of strings | **REQUIRED** | Technology names this pattern applies to, matching entries in the project's `tech_stack`. At least one entry. |
| `domain_tags` | List of strings | **REQUIRED** | Functional categories, e.g., `routing`, `forms`, `deployment`, `build-config`, `testing`, `verification`. Used by context cards to select relevant patterns. At least one entry. |
| `nv_score` | Integer | **REQUIRED** | 0–3. Novelty of the evidence basis. 0 = documented in official sources with known outcomes. 1 = established practice with indirect evidence. 2 = plausible but limited prior evidence. 3 = speculative — should not be seeded; raise as uncertainty instead. |
| `source` | String | **REQUIRED** | Where does this pattern come from? Specific: official documentation URL or title, prior project name and outcome, known community convention with traceable origin. Not: "general knowledge" or "best practice". |
| `nv_score_rationale` | String | **REQUIRED** | One sentence justifying the assigned `nv_score`. Without this, the score cannot be verified independently. |

#### The verification meta-pattern — additional requirements

One pattern in the seed set must serve as the proof-of-completion guide for this project's stack. It holds a special role: it is the pattern that informs how proof templates are written for every task this project produces.

Beyond the standard schema, this pattern must additionally address:

| Additional field | Requirement |
|---|---|
| `domain_tags` includes `verification` | **REQUIRED** — this is how context cards identify it for proof design work |
| `approach` describes the primary evidence type | The approach must name the command, output, or observable state that constitutes proof for this stack. For a static site: "A successful `pnpm build` with exit code 0 and expected output in `dist/` is the primary proof of task completion. Supplement with: [specific to task type]" |
| `applies_when` covers the project's delivery work | Must not be so narrow that it only applies to one task type |

#### Domain coverage map

A structured record produced alongside the pattern entries, showing:

| Field | Requirement |
|---|---|
| Pattern domains identified from the stack | List of functional domains the stack knowledge resources identified as relevant |
| Patterns seeded per domain | Count and pattern IDs |
| Domains with no seeded patterns | Listed explicitly — absence is noted, not hidden |
| Rationale for unseeded domains | If a domain was identified but not seeded (e.g., out of scope per manifest), the rationale is recorded |

#### Review record per pattern

Produced in Task 4.4. Retained as evidence.

| Field | Requirement |
|---|---|
| `pattern_id` | The pattern being reviewed |
| Review criteria results | One result per criterion (see Task 4.4): `PASS` or `FAIL` |
| Evidence per result | Literal reference to the pattern field content that confirms the result |
| Overall verdict | `ACCEPT` (all criteria pass) or `RETURN` (one or more fail) |
| Findings | For `RETURN`: each failing criterion, the specific defect, and what change would resolve it |
| Reviewer identity | Who performed the review |
| Timestamp | ISO 8601 datetime |
| Promotion decision | `PROVISIONAL` if accepted; recorded at time of promotion |

***

## Definition of Done

### Summary

Step 4 is done when all six conditions are simultaneously true:

1. The knowledge base contains at least 5 patterns in `PROVISIONAL` status
2. At least one `PROVISIONAL` pattern carries the `verification` domain tag and meets the additional verification meta-pattern requirements
3. Every `PROVISIONAL` pattern has a complete, schema-conformant entry — no required field is empty
4. Every `PROVISIONAL` pattern has a review record with an `ACCEPT` verdict from a reviewer who did not produce the pattern
5. No `PROVISIONAL` pattern was produced by invention — every field value, including `evidence` and `source`, is traceable to a seeding resource or the project's accepted inputs
6. The domain coverage map is on file and any unseeded domains are documented with rationale

### Unambiguous Requirement Breakdown

#### DoD 1 — At least 5 patterns in `PROVISIONAL` status

- The count is of patterns with `status: PROVISIONAL` — `CANDIDATE` patterns do not count toward the minimum
- Promotion to `PROVISIONAL` requires an `ACCEPT` verdict from the review process; patterns cannot be self-promoted
- The minimum is 5 regardless of project appetite — a `small` project still requires 5 PROVISIONAL patterns before delivery begins
- **Fails if:** Fewer than 5 patterns carry `status: PROVISIONAL`; any `PROVISIONAL` pattern has no review record; any pattern was promoted without an `ACCEPT` verdict

#### DoD 2 — At least one verification meta-pattern

- One pattern in the `PROVISIONAL` set must have `verification` in its `domain_tags`
- That pattern's `approach` field must name a specific, executable command or observable state that constitutes proof of task completion for this project's stack
- The pattern must be consistent with the environment contract's `verification` section — if the contract says the local check is `pnpm build && pnpm preview`, the verification meta-pattern should reflect this, not contradict it
- **Fails if:** No `PROVISIONAL` pattern carries the `verification` domain tag; the verification meta-pattern's `approach` does not name a specific executable command or observable state; the approach contradicts the environment contract's verification section

#### DoD 3 — All `PROVISIONAL` patterns are schema-conformant

- Every field in the pattern schema marked REQUIRED is non-empty for every `PROVISIONAL` pattern
- `applies_when` and `does_not_apply_when` each contain at least one entry per pattern
- `stack_tags` contains at least one entry that matches a technology in the project's `tech_stack`
- `nv_score` is an integer between 0 and 3; no seeded pattern has `nv_score: 3` (speculative patterns are not valid for seeding)
- `nv_score_rationale` is present and is one sentence
- **Fails if:** Any required field is empty or absent in any `PROVISIONAL` pattern; any pattern has `nv_score: 3`; any `nv_score` value has no corresponding rationale

#### DoD 4 — Every `PROVISIONAL` pattern has an independent review record

- A review record exists for every `PROVISIONAL` pattern
- The review record contains results for every review criterion (Task 4.4)
- Every `PASS` result has specific evidence cited from the pattern content
- The overall verdict is `ACCEPT`
- Reviewer identity is present and differs from the identity of the party that documented the pattern
- **Fails if:** Any `PROVISIONAL` pattern lacks a review record; any review record has a `RETURN` overall verdict; any `PASS` result lacks specific evidence; reviewer identity matches the pattern documenter

#### DoD 5 — No pattern was produced by invention

- Every pattern's `source` field identifies a specific, traceable origin
- Every pattern's `evidence` field references a specific, traceable claim — not a general assertion
- Every pattern is consistent with the project's accepted environment contract — no pattern describes a configuration that contradicts the contract
- **Fails if:** Any pattern's `source` is `general knowledge`, `best practice`, or equivalent non-specific text; any pattern's `evidence` is an assertion without a traceable basis; any pattern's `approach` contradicts the environment contract

#### DoD 6 — Domain coverage map is on file

- The domain coverage map exists and identifies all pattern domains surfaced from the stack seeding resources
- Every unseeded domain has a documented rationale: either out of scope per manifest, no applicable seeding resource exists (flagged as a gap), or the domain will be seeded from delivery work
- The map is not required to show complete coverage — gaps are acceptable as long as they are visible
- **Fails if:** The domain coverage map is absent; any unseeded domain has no rationale; the map was not updated to reflect the final `PROVISIONAL` pattern set

***

## Tasks

***

### Task 4.1 — Domain Identification

**Question:** What pattern domains are relevant for this project's declared tech stack?

**Input:** Approved manifest (specifically `tech_stack`, `constraints`, `out_of_scope`, `appetite`); accepted environment contract (all sections); stack seeding resources

**Output:** A domain list — every functional category relevant to this project's approach; each domain classified as `IN_SCOPE`, `OUT_OF_SCOPE` (with rationale from the manifest or contract), or `NO_RESOURCE` (no seeding resource available — flagged for higher-level attention)

**Subtasks:**
- For each technology in `tech_stack`: read the corresponding seeding resource and extract the domain list it identifies
- For each domain: check against `out_of_scope` declarations in the manifest — domains that exclusively serve out-of-scope capabilities are `OUT_OF_SCOPE`
- For each domain: confirm a seeding resource entry exists — if not, classify as `NO_RESOURCE` and flag (this is a potential toolkit gap, not a project gap)
- Add `verification` as an explicit required domain — this is always `IN_SCOPE` regardless of other signals
- For `appetite: small` projects: note which domains are high-priority (directly required for delivery) versus lower-priority (useful but not critical for the first task) — this informs the ordering of Tasks 4.2 and 4.3 but does not reduce the minimum of 5

**Done when:** Every technology in `tech_stack` has been processed against its seeding resource; every domain has an `IN_SCOPE`, `OUT_OF_SCOPE`, or `NO_RESOURCE` classification with rationale; `verification` domain is present and `IN_SCOPE`; any `NO_RESOURCE` domains are flagged

***

### Task 4.2 — Pattern Identification

**Question:** Which patterns from the seeding resources are applicable and sufficiently evidenced for this project?

**Input:** Domain list from Task 4.1; stack seeding resources; accepted environment contract

**Output:** A candidate selection list — for each `IN_SCOPE` domain, the patterns from the seeding resources that are applicable to this project given the specific configuration in the environment contract

**Subtasks:**
- For each `IN_SCOPE` domain: read the corresponding entries in the stack seeding resources
- For each seeding resource entry: apply the applicability filter — is this entry consistent with the project's accepted environment contract? A seeding entry describing `output: server` configuration is not applicable to a project with `output_mode: static`
- For each applicable entry: assess the evidence basis — does the entry reference a specific, traceable source? If the seeding resource entry itself has no evidence basis, it cannot be used
- Do not select more than necessary — the goal is a minimum viable set, not an exhaustive catalogue. For each domain, prefer the highest-evidence entry over multiple lower-confidence entries
- For the `verification` domain: identify the seeding resource entry that best describes proof-of-completion evidence for this stack combination. If no single entry covers the full stack combination (e.g., AstroJS + Netlify together), note that a composite pattern will need to be constructed in Task 4.3

**Done when:** At least 5 applicable, evidenced entries have been selected from the seeding resources; the `verification` domain has at least one selected entry; every selected entry has a traceable evidence basis

***

### Task 4.3 — Pattern Documentation *(loop — one pass per selected pattern)*

**Question:** Can each selected seeding entry be structured into a complete, schema-conformant pattern?

**Input:** Candidate selection list from Task 4.2; pattern schema; accepted environment contract; pattern library (target)

**Output:** One `CANDIDATE` pattern entry in the knowledge base per selected pattern

**For each selected entry:**

**Subtasks:**
- Populate every required schema field from the seeding resource entry and the project's accepted inputs
- `problem`: derive from the seeding resource — make it specific to the project's configuration if the entry is generic. "Where to put AstroJS components" is more useful than "code organisation"
- `approach`: transcribe from the seeding resource; make it concrete and actionable; remove any hedging language ("it may be better to…") — if the approach cannot be stated without hedging, the evidence basis is insufficient and the pattern should not be created
- `evidence`: cite the specific source; include the claim the source makes; do not paraphrase in a way that changes the meaning
- `applies_when` and `does_not_apply_when`: derive from the seeding resource; supplement with project-specific conditions from the environment contract
- `stack_tags`: include all technologies from the project's `tech_stack` that are relevant to this pattern; do not include technologies not in the project's stack
- `nv_score` and `nv_score_rationale`: assign based on the evidence basis quality — official documentation with a specific verifiable claim = 0; established community practice with indirect evidence = 1; plausible but limited evidence = 2; never assign 3 to a seeded pattern
- Set `status: CANDIDATE`
- Write the entry to the knowledge base

**For the verification meta-pattern specifically:**
- If a single seeding resource entry covers the full stack combination (e.g., AstroJS + Netlify + pnpm), document it directly
- If no single entry covers the combination, construct a composite: the `approach` describes the primary proof command from the contract's `verification.local_check`, supplemented by deployed verification from `verification.deployed_check`; the `evidence` cites each component's source separately; `applies_when` is specific to this project's stack combination
- A composite pattern requires the constructor to document which seeding entries it was composed from in the `source` field

**Self-check before completing each pattern:**
- Every required field is non-empty
- `approach` contains no hedging language
- `evidence` cites a specific source with a specific claim
- `applies_when` and `does_not_apply_when` each have at least one entry
- `nv_score` is 0, 1, or 2 — never 3
- The pattern is consistent with the environment contract — no field contradicts a contract entry
- `status: CANDIDATE`

**Done when (per pattern):** All required fields populated; schema-conformant; written to the knowledge base as `CANDIDATE`

***

### Task 4.4 — Pattern Review *(loop — one pass per candidate pattern)*

**Question:** Does each candidate pattern meet the quality criteria for promotion to `PROVISIONAL`?

**Input:** Each `CANDIDATE` pattern from Task 4.3

**Output:** A review record per pattern — `ACCEPT` (promote to `PROVISIONAL`) or `RETURN` (specific findings for revision)

**This task is performed by a different party from the one that documented the patterns.**

**Review criteria — applied to each pattern:**

| Criterion | What `PASS` looks like | What `FAIL` looks like |
|---|---|---|
| **Clarity** | Problem is stated specifically; a role can determine in ≤ 30 seconds whether its task has this problem | Problem is vague; could apply to any task; requires interpretation to apply |
| **Reusability** | Approach applies to a class of tasks, not one specific task; `applies_when` is broad enough to cover multiple future tasks | Approach describes one task's implementation; would not apply to the second task of the same type |
| **Evidence plausibility** | `evidence` cites a specific, traceable source; the claim the source makes is consistent with the `approach` | Evidence is asserted ("this is known to work") or cites a non-specific source; claim cannot be verified |
| **Applicability specificity** | `does_not_apply_when` contains at least one condition that would genuinely exclude incorrect use; conditions are specific | `does_not_apply_when` is generic ("when not applicable") or absent; pattern appears to apply everywhere |
| **Schema conformance** | All required fields are non-empty; `nv_score` is 0–2; `nv_score_rationale` is present; `stack_tags` matches project stack | Any required field empty; `nv_score: 3`; `stack_tags` contains technologies not in the project stack |
| **Contract consistency** | No field contradicts the accepted environment contract | Any field describes a configuration incompatible with the contract |
| **Verification meta-pattern (if applicable)** | `approach` names a specific executable command or observable state; consistent with contract's `verification` section | Approach is generic; does not name a specific command; contradicts the contract's verification section |

**Verdict:**
- `ACCEPT`: all criteria pass — promote the pattern to `PROVISIONAL` (set `status: PROVISIONAL`, update `last_reviewed`, record reviewer identity and timestamp)
- `RETURN`: one or more criteria fail — produce findings list; each finding specifies the criterion, the defect, and what change would resolve it

**If `RETURN`:** The pattern goes back to Task 4.3 with findings attached. Task 4.3 addresses each finding and produces a revised entry. Task 4.4 runs again. This loops until `ACCEPT` or until the pattern is determined to be unsalvageable — in which case it is removed from the candidate set and the domain coverage map is updated to note the gap.

**After all review cycles:** Confirm the minimum viable set:
- Count `PROVISIONAL` patterns: is the count ≥ 5?
- Is at least one `PROVISIONAL` pattern in the `verification` domain?
- If either condition is not met: return to Task 4.2 to identify additional candidates for the deficient domains; do not proceed to Task 4.5

**Done when (per pattern):** `ACCEPT` verdict recorded; `status: PROVISIONAL`; review record filed with reviewer identity and timestamp; reviewer identity differs from the pattern documenter

***

### Task 4.5 — Domain Coverage Map and Step Completion Record

**Question:** Is the minimum viable set complete, and are any domain gaps documented?

**Input:** All `PROVISIONAL` patterns; domain list from Task 4.1

**Output:** Domain coverage map; Step 4 completion entry in the project's bootstrap record

**Subtasks:**
- For each `IN_SCOPE` domain from Task 4.1: list the `PROVISIONAL` patterns covering it
- For each `IN_SCOPE` domain with no `PROVISIONAL` patterns: document the gap and its rationale
  - If the gap is because seeding resources had no applicable entry: flag as F15 (toolkit gap)
  - If the gap is because all candidates were rejected in review: flag as a quality gap; document what was attempted
  - If the gap is because the domain was deprioritised and the minimum is already met: document this explicitly as a known gap to be addressed from delivery work
- Confirm: count of `PROVISIONAL` patterns is ≥ 5
- Confirm: at least one `PROVISIONAL` pattern carries `verification` domain tag
- Write the domain coverage map to `[project-root]/.framework/pattern-library/seed-coverage.md`
- Write the Step 4 completion entry to the bootstrap record: number of PROVISIONAL patterns, domains covered, domains with gaps, verification meta-pattern confirmed present

**Done when:** Domain coverage map is complete; every unseeded `IN_SCOPE` domain has a documented rationale; both minimum viable set conditions are confirmed; completion entry is filed with timestamp

***

## Items to Flag for Higher-Level Consideration

**F15 — Stack Seeding Resources as a Toolkit Dependency**
Step 4 requires the toolkit to contain seeding resources for every technology that might appear in a project's `tech_stack`. If a resource is absent, patterns for that technology cannot be produced. This is a toolkit maintenance requirement — the toolkit must grow its seeding resources as new technology stacks are supported. The governance of seeding resource currency (keeping resources current as technology versions change) and coverage (adding resources for new stacks) belongs at framework level.

**F16 — The NV Score System Applied to Patterns**
The NV score in the pattern schema (0–3) applies the same novelty classification used in the agent creation policy. A `nv_score: 3` pattern is speculative and should not be seeded. But the boundary between 1 and 2 requires judgment — the framework needs an explicit decision table for NV scoring that applies consistently across Steps 4 and any future knowledge base work. The rubric in the agent creation policy provides the model; it needs to be adapted for pattern entries.

**F17 — The Pattern Lifecycle Beyond Seeding**
This step sets patterns to `PROVISIONAL`. The lifecycle from `PROVISIONAL` to `ACTIVE` happens during delivery — when a pattern is selected for a context card and the task completes successfully, evidence accumulates toward `ACTIVE` promotion. The conditions for that promotion, and the governance of `DEPRECATED` transitions, are not defined here. This is a framework-level knowledge management concern.

**F18 — The Verification Meta-Pattern as a Composite**
When no single seeding resource covers the full stack combination, Task 4.3 requires constructing a composite verification meta-pattern. Composite pattern construction is qualitatively different from transcribing a single entry — it requires combining evidence from multiple sources. The rules for composite pattern construction (how to cite multiple sources, how to assign NV score to a composite, how to handle conflicting evidence from component sources) belong at framework level.

**F19 — Cross-Project Pattern Inheritance**
This step seeds patterns from the toolkit's knowledge resources, starting from zero each time. For a second or subsequent project using the same tech stack, patterns already proven in the first project are immediately relevant. The mechanism for promoting patterns from one project's knowledge base to the toolkit's seeding resources — so subsequent projects benefit — belongs at framework level. Without it, every project starts with the same generic seed set regardless of accumulated evidence.