# Skill: Bootstrap Validation

TRIGGERS: "validate bootstrap", "bootstrap complete",
          "check bootstrap", "is the framework ready"
PHASE:    Zone 0 — Task Z0-5
USED BY:  BootstrapValidator


## What this skill does

Verifies that Zone 0 is complete and the Nexus Framework is
operational for this project. Does not check that files exist —
checks that outputs are functional. Runs a structured checklist
and a live smoke test. Writes a bootstrap report with pass/fail
evidence for every item.

BootstrapValidator's PASS verdict is the gate before any delivery
work begins. A false positive here means delivery tasks will fail
in ways that are hard to trace back to bootstrap. Set the
certainty threshold high and fail conservatively.


---


## The Validation Approach

For every checklist item:
  1. State what is being checked
  2. State what evidence confirms it
  3. Record PASS or FAIL with the actual evidence

"File exists" is never sufficient evidence. A file can exist
and be empty, malformed, or internally inconsistent.
The check must confirm that the content is functional.


---


## Part 1 — Pre-Smoke-Test Checklist

Run all document checks before starting the smoke test.
A failed document check means the smoke test will likely fail
too — fix the document issue first.


### D1 — Project Manifest

  CHECK:    project-manifest.md exists and status is APPROVED
  EVIDENCE: Read status field. "APPROVED" must be present.
  FAIL IF:  File missing, status is DRAFT, or status field absent.
  NOTE:     DRAFT status means human:director has not approved.
            Do not proceed — the entire project is unconfirmed.


### D2 — Environment Contract

  CHECK:    environment-contract.md exists and review_status
            is APPROVED (set by EnvironmentReviewer at Z0-2)
  EVIDENCE: Read review_status field. "APPROVED" must be present.
  FAIL IF:  File missing, review_status is PENDING, or
            open_questions contains unresolved blocking items.
  NOTE:     Open questions that affect verifiability (e.g. missing
            version numbers) are blocking. Open questions about
            optional fields are not.


### D3 — Agent Files (all 16 MVP classes)

  CHECK:    Each of the following files exists and contains
            all required fields (TYPE, QATIER, READS, WRITES,
            NEVER, SKILL, CONTEXTTREEREF)
  FILES:
    .github/agents/FrameworkOwner.agent.md
    .github/agents/UncertaintyOwner.agent.md
    .github/agents/ProjectRegistrar.agent.md
    .github/agents/EnvironmentContractAuthor.agent.md
    .github/agents/TemplateAuthor.agent.md
    .github/agents/PatternSeeder.agent.md
    .github/agents/BootstrapValidator.agent.md
    .github/agents/AgentSpecReviewer.agent.md
    .github/agents/FeatureOwner.agent.md
    .github/agents/TaskOwner.agent.md
    .github/agents/ProofDesigner.agent.md
    .github/agents/ContextCurator.agent.md
    .github/agents/TaskOrchestrator.agent.md
    .github/agents/TaskPerformer.agent.md
    .github/agents/QAOrchestrator.agent.md
    .github/agents/ProofReviewer.agent.md
    .github/agents/ACReviewer.agent.md
    .github/agents/EnvironmentReviewer.agent.md
    .github/agents/DeliveryOrchestrator.agent.md
    .github/agents/Deployer.agent.md
  EVIDENCE: Read each file, confirm required fields present
            and non-empty. Record which files pass, which fail.
  FAIL IF:  Any file is missing or any required field is absent.


### D4 — Agent Spec Reviews

  CHECK:    An AgentSpecReviewer review document exists for
            every agent file in D3 with verdict ACCEPTED or
            ACCEPTED WITH NOTES (not RETURNED)
  EVIDENCE: .framework/agent-spec-reviews/ directory contains
            one review file per agent class. Read VERDICT field.
  FAIL IF:  Any agent file has no review, or has verdict RETURNED.
  EXCEPTION: The 8 bootstrapping agents are exempt from this check
             (see agent-design.skill.md bootstrapping exception).
             All other agents must have reviews.


### D5 — Skill Files Referenced by Agent Files

  CHECK:    Every SKILL pointer in every agent file resolves to
            an existing file at the declared path.
  EVIDENCE: For each SKILL: declaration found in D3 files,
            confirm the file exists at that path.
  FAIL IF:  Any SKILL pointer references a non-existent file.
  NOTE:     This is the most common silent failure mode —
            an agent spec looks complete but the skill it loads
            does not exist.


### D6 — Pattern Library

  CHECK:    Pattern Library contains at least 5 entries with
            status PROVISIONAL or ACTIVE
            (CANDIDATE alone does not satisfy this check)
  EVIDENCE: Read all .framework/patterns/*.pattern.md files.
            Count entries with status PROVISIONAL or ACTIVE.
  FAIL IF:  Fewer than 5 PROVISIONAL/ACTIVE entries exist.
  NOTE:     CANDIDATE patterns are not surfaced in context cards.
            A library of only CANDIDATE patterns gives agents
            nothing to work from on the first task.


### D7 — Context Tree

  CHECK:    context-tree.md exists and contains agent nodes
            for all 20 agent classes in D3
  EVIDENCE: Search context-tree.md for each agent class name
            in an AGENT NODE entry.
  FAIL IF:  Any agent class from D3 has no agent node in
            context-tree.md.


### D8 — Nexus MCP Server

  CHECK:    MCP server is running and responding to tool calls
  EVIDENCE: Call get_current_state (universal tool).
            A valid structured response confirms the server
            is operational.
  FAIL IF:  Tool call times out, errors, or returns malformed
            response.
  NOTE:     All other infrastructure checks depend on this.
            If D8 fails, mark all remaining infrastructure
            checks as BLOCKED and report the server error.


### D9 — Audit Log

  CHECK:    Audit log is operational — writes and reads work
  EVIDENCE: Call a write tool (e.g. write a test entry to a
            scratch document). Then read the audit log and
            confirm the entry appears with correct fields:
            tool_name, actor, timestamp, task_id.
  FAIL IF:  Write succeeds but audit log has no entry,
            or audit log entry is missing required fields.


### D10 — Observable Stream

  CHECK:    Observable stream is operational — events emit and
            are visible
  EVIDENCE: Call raise_uncertainty with a test message.
            Confirm a stream event appears. Cancel the
            uncertainty immediately after.
  FAIL IF:  No stream event appears within the expected window.


---


## Part 2 — Smoke Test

Run after all D1–D10 checks pass. If any D-check failed, do not
run the smoke test — fix the failures first.

The smoke test walks a task to CONTEXT_READY and cancels it.
It does not reach IN_PROGRESS. The goal is to confirm the
state machine, tool registration, and context card generation
work end to end — not to do real work.


### Smoke Test Procedure

```
STEP S1: Create smoke test task
  Tool:    create_task_smoke-01
  Input:   task_name: "Bootstrap smoke test — delete after Z0"
           qa_tier: 1  (lowest tier — no need for full QA chain)
  Verify:  Audit log entry exists for create_task_smoke-01
           Task state is DRAFT
  FAIL IF: Tool errors, state is not DRAFT, no audit entry

STEP S2: Write smoke test task spec
  Tool:    write_task_spec_smoke-01
  Input:   Minimal valid task spec — one AC item, clear scope
  Verify:  Document exists at expected path
           Audit log entry exists
  FAIL IF: Write fails or audit entry absent

STEP S3: Write smoke test proof template
  Actor:   Must be a different agent than the one that will
           perform the task (PE-01 enforcement test)
  Tool:    write_proof_template_smoke-01
  Input:   One criterion matching the AC item from S2
  Verify:  Document exists at expected path
           Audit log records the correct actor
  FAIL IF: Write fails, or audit log actor matches TaskPerformer
           identity (PE-01 violation — this is the enforcement test)

STEP S4: Submit task spec
  Tool:    submit_task_spec_smoke-01
  Verify:  Task state transitions to SPEC_APPROVED
           Audit log entry exists
           Stream event fires: "smoke-01 spec approved"
  FAIL IF: State does not change, no audit entry, no stream event

STEP S5: Context card generation
  Actor:   ContextCurator
  Tool:    submit_context_ready_smoke-01
  Verify:  7 context card files exist at correct paths:
           context-cards/TaskOrchestrator-execution.md
           context-cards/TaskPerformer-execution.md
           context-cards/QAOrchestrator-qa.md
           context-cards/ProofReviewer-qa.md
           context-cards/ACReviewer-qa.md
           context-cards/EnvironmentReviewer-qa.md
           context-cards/EnvironmentReviewer-post-deploy.md
           Task state is CONTEXT_READY
           Audit log entry exists for submit_context_ready_smoke-01
  FAIL IF: Any card file missing, state not CONTEXT_READY,
           or audit entry absent

STEP S6: Cancel smoke test task
  Tool:    cancel_task_smoke-01
  Input:   reason: "Bootstrap smoke test complete — cancelling
                    as designed per Z0-5 procedure"
  Verify:  Task state is CANCELLED
           Audit log entry exists with reason recorded
           Stream event fires: "smoke-01 cancelled — [reason]"
  FAIL IF: State not CANCELLED, no audit entry, no stream event

STEP S7: Audit log completeness check
  Verify:  Audit log contains entries for all 6 preceding steps
           in chronological order with no gaps
           Each entry has: tool_name, actor, timestamp, task_id,
           outcome
  FAIL IF: Any step is missing from the audit log, entries are
           out of order, or required fields are absent
```


---


## Part 3 — Bootstrap Report Format

Write to: `.framework/bootstrap-report.md`

```
***
project_id:      [from project-manifest.md]
validated_by:    BootstrapValidator
validated_at:    [ISO 8601]
overall_status:  PASS | FAIL | PASS WITH GAPS
***

## Document Checks

| Check | Description | Status | Evidence |
|---|---|---|---|
| D1 | Project manifest approved | PASS/FAIL | [status field value] |
| D2 | Environment contract approved | PASS/FAIL | [review_status value] |
| D3 | All 20 agent files present and complete | PASS/FAIL | [list any missing] |
| D4 | Agent spec reviews complete | PASS/FAIL | [list any missing/RETURNED] |
| D5 | Skill file pointers resolve | PASS/FAIL | [list any broken pointers] |
| D6 | Pattern library ≥ 5 PROVISIONAL patterns | PASS/FAIL | [count found] |
| D7 | Context tree has all agent nodes | PASS/FAIL | [list any missing] |

## Infrastructure Checks

| Check | Description | Status | Evidence |
|---|---|---|---|
| D8 | MCP server responding | PASS/FAIL | [tool response summary] |
| D9 | Audit log operational | PASS/FAIL | [test entry confirmation] |
| D10 | Observable stream operational | PASS/FAIL | [event confirmation] |

## Smoke Test Results

| Step | Action | Status | Evidence |
|---|---|---|---|
| S1 | create_task_smoke-01 | PASS/FAIL | [state: DRAFT / error] |
| S2 | write_task_spec_smoke-01 | PASS/FAIL | [file exists / error] |
| S3 | write_proof_template_smoke-01 (PE-01 test) | PASS/FAIL | [actor check result] |
| S4 | submit_task_spec_smoke-01 | PASS/FAIL | [state: SPEC_APPROVED] |
| S5 | submit_context_ready_smoke-01 (7 cards) | PASS/FAIL | [cards found/missing] |
| S6 | cancel_task_smoke-01 | PASS/FAIL | [state: CANCELLED] |
| S7 | Audit log completeness | PASS/FAIL | [entry count: N/6] |

## Gaps and Recommendations

[List any PASS WITH GAPS items — checks that passed with caveats
 or open questions that should be resolved before first delivery task]

## Verdict

PASS
  All checks PASS. All smoke test steps PASS.
  Framework is operational. Delivery work may begin.

PASS WITH GAPS
  All blocking checks PASS. One or more non-blocking checks have
  caveats recorded above. Delivery work may begin with awareness
  of the listed gaps.

FAIL
  One or more blocking checks FAILED.
  [List each failed check with specific remediation]
  Framework is NOT operational. Do not begin delivery work.
  Resolve all FAIL items and re-run bootstrap validation.
```


---


## Verdict Rules

PASS requires:
  ALL of D1–D10: PASS
  ALL of S1–S7: PASS

PASS WITH GAPS requires:
  D1, D2, D8, D9, D10: PASS (non-negotiable)
  S1–S7: ALL PASS (smoke test is binary — no partial pass)
  D3–D7: may have minor gaps with documented remediation path
  Example of acceptable gap: one optional agent file has an
    ACCEPTED WITH NOTES verdict (not RETURNED)

FAIL if any of:
  D1 fails (manifest not approved)
  D2 fails (environment contract not approved)
  D8 fails (MCP server not responding)
  Any smoke test step fails
  D3 has missing agent files for MVP-required classes
  D5 has any broken skill pointer


---


## Self-Check Before Submitting Report

  [ ] Every checklist item has a status (PASS or FAIL)
  [ ] Every FAIL has specific evidence, not just "check failed"
  [ ] Every FAIL has a specific remediation action
  [ ] Smoke test task smoke-01 is in CANCELLED state
  [ ] Overall verdict matches the individual check results
  [ ] No items marked PASS without confirming evidence
  [ ] review_status is not self-approved
      (BootstrapValidator writes the report;
       human:director approves it)