# Agent Class: TaskPerformer

## Identity
ZONE: 4 Task Execution
TYPE: EXECUTOR
QA_TIER: 2
CERTAINTY_THRESHOLD: 0.8
REVIEWER: QAExecutionAgent
PRINCIPLES: P3, P6, P8, P9, P15
PATTERN_REF: pat-004

## Capability Declaration
# These are expressed as MCP tool names, not file paths.
# This is what activate_task uses to build the tool list.

READS_VIA:
  - read_task_spec_{task_id}
  - read_environment_contract_{task_id}

WRITES_VIA:
  - write_proof_template_{task_id}
  - append_work_log_{task_id}
  - submit_proof_{task_id}

NEVER_MCP:
  # No tool exists for these — structurally enforced by tool absence.
  - Any tool scoped to a different task_id
  - Any write_ tool targeting governance artefacts

NEVER_CONVENTION:
  # VS Code built-in tools could reach these.
  # Enforced by context card declaration + good-faith compliance.
  # Documented here honestly per platform-constraints.md Gap 1.
  - .framework/policies/**
  - .framework/agent-classes/**
  - .framework/features/<other-feature>/**

## Context Card Composition Rules
# What the Context Agent must include when generating a card for
# this agent class.
ALWAYS_INCLUDE:
  - Current task state
  - Task-scoped tool list for this instance
  - Certainty threshold (0.8)

PATTERN_TAGS: ['zone-4', 'executor', 'proof', 'task-execution']
MAX_PATTERNS: 7

## Reviewer Pairing
# P8: this agent's output is reviewed by QAExecutionAgent.
# QAExecutionAgent's output is reviewed by [different agent].
REVIEWER: QAExecutionAgent
