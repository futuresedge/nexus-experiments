# Hypothesis Card — H-SKILLS-01
## Skill Files Are Accessible Without Read Tools

**Hypothesis:**
An agent with zero read tools can access the full content of a
referenced skill file, because VS Code loads it at the host layer,
not via a tool call.

**Test:**
1. Create a minimal agent with only universal MCP tools (no read_,
   no VS Code built-in file tools)
2. Reference a skill in the instructions file via `#skill-name`
3. Ask the agent to describe what it knows about its task format
4. Inspect whether skill content appears in its response without
   any tool call in the audit log

**Pass condition:**
Agent accurately describes skill content. Zero read_ entries in
audit_log. No VS Code file tool calls visible in the trace.

**Fail condition:**
Agent cannot access skill content, OR accesses it via an unaudited
VS Code built-in read — meaning skill content loads but bypasses
the audit trail entirely.

**Why this matters:**
If PASS: skill files are a clean VS Code-layer delivery mechanism —
no tool needed, no audit gap, intentional by design.
If FAIL (access via built-in): we have an unaudited read path for
skill content that needs to be documented in platform-constraints.md
as Gap 5.
If FAIL (no access): skills must be delivered via get_context_card
instead, which changes the composition rules.

**Blocking:** No. Run as part of Experiment 02 setup.

## Result: 

# H-SKILLS-01 — PASS
**Date:** 2026-03-04
**Tested by:** FO (manual)

**Finding:**
VS Code injects skill file content at the host layer before the agent
runs. No read tool is required. No MCP tool call is made. The agent
receives skill content regardless of what tools it holds.

**Evidence:**
Agent with only edit tools (no read_, no get_, no VS Code built-in
file read) successfully accessed and applied 'skill-writing' skill
content when asked to produce a skill file.

**Implication for audit:**
Skill reads produce no audit_log entry. This is not a gap — it is
correct behaviour. Skills are role knowledge (how to do the job),
not task data (what this specific task requires). The audit log
records decisions and outputs, not the professional knowledge the
agent applies to make them. A surgeon's training doesn't appear
in the operation notes.

**Status:** Confirmed architectural property. Not a gap.


---

Method:

I personally ran the H-SKILLS-01 experiment and it passed! This is the agent file I created and asked it to create a skill for writing html5 base template. It access the 'skill-writing' skill in the skills library without requiring access to the `read` tool.

```markdown
---
name: Skillful Agent
description: Can access skills without read access
tools: [edit/createDirectory, edit/createFile, edit/editFiles]
---

You are an expert at writing skills for VSCode copilot agents.
```