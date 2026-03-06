# Skill: Project Registration

TRIGGERS: "register project", "create project manifest",
          "project brief", "start new project", "initialise project"
PHASE:    Zone 0 — Task Z0-1
USED BY:  ProjectRegistrar


## What this skill does

Translates a human:director project brief (freeform input) into a
structured, machine-readable project manifest. The manifest is a
faithful restatement of intent — not an interpretation, not an
enhancement, not a best-guess completion of what was unsaid.

The manifest is the root reference document for the entire project.
Every downstream artefact traces back to it. An error introduced
here propagates to everything.


## The Prime Directive

Never invent a value. If a required field cannot be populated from
what human:director provided, raise uncertainty for that field.

A manifest with explicit open_questions is correct.
A manifest with silently assumed values is dangerous.
The human will not notice a wrong assumption — only the problem
it eventually causes.


---


## Part 1 — Manifest Schema

Fields marked REQUIRED must be non-empty before submission.
Fields marked OPTIONAL may be empty — record as `[]` or `""`,
never omit the field entirely.

```
project_id:
  REQUIRED
  kebab-case slug. Derive from project_name if not provided.
  Rule: lowercase, hyphens only, no spaces, no special characters
  Example: "petes-plumbing-site"

project_name:
  REQUIRED
  Human-readable name exactly as stated by human:director.
  Do not normalise, correct, or rewrite. Use their words.
  Example: "Pete's Plumbing Website"

description:
  REQUIRED
  2–4 sentences. What is being built and for whom.
  Derived from the brief. Do not add context that was not given.
  If the brief is vague: write what was said and flag the vagueness
  in open_questions.

tech_stack:
  REQUIRED — at least one named technology
  List of specific named technologies. Not categories.
  ACCEPT:  ["AstroJS 5.x", "Tailwind CSS 4", "Netlify"]
  REJECT:  ["modern frontend stack", "standard tooling"]
  If no tech stack declared: raise uncertainty before writing
  any other field. Everything downstream depends on this.

deployment:
  REQUIRED
  Named deployment target. Minimum: provider name.
  Ideal: provider + target URL + environment structure (prod/staging)
  If absent: raise uncertainty.

human_actors:
  REQUIRED — at least one entry
  Format per entry: { name, role }
  Valid roles: human:director | human:approver | other:[description]
  At least one human:director must exist.
  human:director and human:approver may be the same person —
  record both roles on the same entry if so.
  If roles not stated: ask before writing other fields.

appetite:
  REQUIRED
  One of: small | medium | large | [explicit duration if stated]
  Do not infer from project size or complexity.
  small:  days of agent work, tight scope
  medium: one to two weeks, moderate scope
  large:  multi-week, broad scope
  If not stated by human:director: raise uncertainty. Do not guess.

constraints:
  OPTIONAL — may be empty []
  Named technical or business constraints as stated.
  INCLUDE: "no React", "Lighthouse score ≥ 90",
           "no third-party form service", "must support IE11"
  EXCLUDE: anything not explicitly stated by human:director
  Do not infer constraints from the tech stack declaration.

out_of_scope:
  OPTIONAL — may be empty []
  What will explicitly NOT be built, as stated.
  Do not infer out-of-scope from what was not mentioned.
  Absence of mention ≠ out of scope.

open_questions:
  OPTIONAL — often non-empty on first draft
  Every gap or ambiguity in the input goes here.
  Format per entry: { question, why_it_matters }
  open_questions do not block submission — they are surfaced
  for human:director to resolve at the approval gate.

status:
  REQUIRED — set by registration process
  DRAFT on creation
  APPROVED only when human:director explicitly approves

created:
  REQUIRED — ISO 8601 date
```


---


## Part 2 — Input Translation Rules

### Technology declarations

Map imprecise declarations to specific entries where the mapping
is unambiguous. Record the original term in open_questions if
the mapping required an assumption.

  "Astro"          → "AstroJS" (note version unknown in open_questions)
  "Tailwind"       → "Tailwind CSS" (note version unknown)
  "Netlify"        → "Netlify" (deployment target, not a framework)
  "React"          → "React" (framework)
  "TypeScript"     → "TypeScript"
  "just use Vite"  → raise uncertainty — Vite alone is not a stack

Do not assume a version if one was not given. Record it as:
  "AstroJS (version not specified)"
and add to open_questions: "AstroJS version not specified —
required for environment contract. Which version?"


### Appetite declarations

Map informal statements to the three-tier vocabulary:

  "quick", "just a few pages", "small site"      → small
  "a few days", "this weekend"                    → small
  "a couple of weeks", "moderate scope"           → medium
  "big project", "lots of features", "months"     → large
  A specific duration stated ("3 weeks")          → record verbatim

If the brief implies large scope but human:director says "small" —
record "small" and add to open_questions:
  "Appetite declared as small but scope appears larger —
   confirm which takes precedence: timeline or scope?"


### Human actors

If human:director does not name actors:
  - Single person project: assume they are both human:director
    and human:approver — record both roles, add to open_questions:
    "Assumed same person is human:director and human:approver —
     confirm or name separate approver."
  - Team project: raise uncertainty — cannot assume who holds
    which role.


---


## Part 3 — What to Raise as Uncertainty vs Open Question

These are different:

UNCERTAINTY (raise_uncertainty — blocks progress):
  - Tech stack not declared at all (cannot write Z0-2 without it)
  - No human:director identified (cannot proceed without authority)
  - Description so vague it could describe any project
    (cannot establish what is in scope vs out of scope)

OPEN QUESTION (record in open_questions — does not block):
  - Version numbers missing from tech stack
  - Appetite not explicitly stated (can proceed with best-match,
    flagged for confirmation)
  - Constraints probably exist but not stated
  - Out-of-scope probably exists but not stated

The test: would getting this wrong cause Z0-2 or Z0-3 to fail?
  YES → uncertainty (raise it, block, wait for resolution)
  NO  → open question (record it, submit, let human:director
         resolve at approval gate)


---


## Part 4 — Manifest Output Format

Write to: `.framework/project-manifest.md`

```
***
project_id:    [value]
project_name:  [value]
status:        DRAFT
created:       [ISO 8601]
***

## Description
[2–4 sentences verbatim from brief or minimally translated]

## Tech Stack
- [technology 1]
- [technology 2]
...

## Deployment
[provider + details as available]

## Human Actors
- name: [name], role: human:director
- name: [name], role: human:approver
...

## Appetite
[small | medium | large | explicit duration]

## Constraints
[list or "None stated"]

## Out of Scope
[list or "None stated"]

## Open Questions
[list of { question, why_it_matters } or empty]
```


---


## Self-Check Before Submitting

  [ ] All REQUIRED fields are non-empty
  [ ] No value was invented — every field traces to something
      human:director said
  [ ] project_id is valid kebab-case
  [ ] At least one human:director exists in human_actors
  [ ] Tech stack has at least one named technology
  [ ] If any ambiguous translation was made, it appears in
      open_questions
  [ ] status is DRAFT (never self-approve)
  [ ] open_questions contains every gap found — nothing silently
      assumed that would surprise human:director at approval