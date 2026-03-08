# Task skills and failure modes

To produce the subtask/skills/failure-modes list, an agent needs specific **context loaded** and a set of **meta-skills**.

***

## Context Needed

- Step 1 policy document for all five tasks (1.1–1.5), including:
  - Original task descriptions, inputs, outputs, and Done-When criteria. 
  - Updated artefact schemas (`brief-inventory.yaml`, `open-questions-register.yaml`, CE/RR/CR series, `project-manifest.yaml`, traceability record). 
- Framework cross-cutting policies:
  - FC-1 No-Invention Invariant (traceability rules). 
  - FC-2 Gap Classification Taxonomy (BLOCKER / WARNING / INFO; gap_type). 
  - FC-3 Clarification Protocol (one-question-per-gap, exchange records). 
  - FC-4 Human Approval Record Pattern (approvalstatement, approvedat/by). 
  - FC-8 Carry-forward of Open Questions between steps. 
  - FC-9 Human Decision Support Protocol (DECISION-REQUIRED path).  
- Decision log:
  - Final Task 1.1 subtask structure (five subtasks, no "read-only" subtask, standing instruction instead). 
  - Vocabulary changes (BLOCKER/WARNING/INFO, gap_type enums). 
  - Artefact format decisions (.yaml vs .md, one-agent-per-artefact, one-write). 

***

## Skills Needed

- **Policy digestion and normalisation**
  - Read multi-page policy + analysis docs and normalise:
    - Tasks → subtasks → operations.
    - Inputs/outputs → concrete artefact schemas.
  - Extract stable behaviour from narrative text (e.g., "what the executor actually does per subtask"). 

- **Process decomposition**
  - Turn each task into:
    - Clear subtask boundaries.
    - Explicit inputs and outputs per subtask.
    - Dependency order (what must exist before what). 

- **Schema- and artefact-awareness**
  - Understand and apply:
    - `brief-inventory.yaml` arrays and cross-references. 
    - Register schema (questionid, gap_type, classification, linked_questions, schema_gap_flag). 
    - Exchange/Review/Correction record schemas (CE-*, RR-*, CR-*). 
    - Manifest + traceability record pairing. 

- **Cross-cutting FC policy mapping**
  - Map FC-1/2/3/4/8/9 requirements onto concrete actions in each subtask:
    - Where FC-1 demands traceability.
    - Where FC-3 constrains questions.
    - Where FC-4 constrains approval handling. 

- **Failure-mode identification**
  - For each subtask:
    - Identify one or more dominant ways it can go wrong.
    - Tie each failure to a specific downstream consequence (later task breakage, FC-1/FC-4 violation). 

- **Consistency checking**
  - Ensure:
    - Skill lists match what the policies and examples actually require.
    - Failure modes are aligned with real observed problems in the case study, not hypothetical only. 

