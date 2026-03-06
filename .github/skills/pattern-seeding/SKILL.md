# Skill: Pattern Seeding

TRIGGERS: "seed patterns", "initialise pattern library",
          "bootstrap patterns", "create initial patterns"
PHASE:    Zone 0 — Task Z0-4
USED BY:  PatternSeeder


## What this skill does

Produces the initial Pattern Library entries for a project's declared
tech stack. These entries give agents something to work from on the
first delivery task rather than starting with an empty library.

Seeds are not invented. Every entry describes a real, known-good
approach. A seeded pattern with no plausible evidence basis is worse
than no pattern — it will be applied confidently and may produce
wrong outcomes that are hard to attribute.

All seeds are CANDIDATE status. FrameworkOwner promotes to
PROVISIONAL. PatternSeeder never self-promotes.


---


## Part 1 — Pattern Schema

Every entry must contain all fields. No field may be omitted.

```
pattern_id:        [kebab-case unique identifier]
title:             [Short verb-noun: "Astro static output for Netlify"]
status:            CANDIDATE
source:            seeded
created:           [ISO 8601]
promoted_by:       [empty until FrameworkOwner acts]
promoted_date:     [empty until FrameworkOwner acts]
usage_count:       0
failure_count:     0

problem:
  [One sentence. What specific situation does this address?
   Must be concrete — not "how to write good code".]

approach:
  [How to address the problem. Concrete enough to act on.
   An agent reading this should know what to do.
   Not: "follow best practices"
   Yes: "Set output: 'static' in astro.config.mjs and add
        @astrojs/netlify adapter to astro.config.mjs integrations"]

evidence:
  [Why this works. For seeds, evidence is prior knowledge of
   the tech stack — acceptable at CANDIDATE stage.
   Cite the source type: "AstroJS docs", "Netlify deploy docs",
   "known framework convention", "prior project experience"
   Do not write "it's a good idea" — that is not evidence.]

applicability:
  [When to apply this pattern. Specific conditions.
   Must be narrow enough that ContextCurator can decide
   whether to include it without reading the full entry.]

contraindications:
  [When NOT to apply. At least one entry required.
   A pattern with no contraindications is a principle, not
   a pattern — it should be rejected by FrameworkOwner.]
```

Write to: `.framework/patterns/{pattern_id}.pattern.md`


---


## Part 2 — Seeding Strategy

Seed in this order. Earlier categories have more leverage.


### Category 1 — Meta-patterns (seed first, for every project)

Meta-patterns are about how the framework operates on this stack,
not about the stack itself. They inform ProofDesigner and
ContextCurator before the first task runs.

Always seed at least one meta-pattern per project. The most
important is the proof evidence pattern — it tells ProofDesigner
what evidence format to use for this stack's tasks.

  proof-by-build-success
    Problem: TaskPerformer needs to provide evidence that code
             works without requiring a deployed environment.
    Approach: Primary evidence for any task that produces build
              artefacts is the captured output of the build command
              (e.g. `pnpm build`) including exit code. Secondary
              evidence is `pnpm preview` + browser verification
              of specific outcomes.
    Applies to: any task that produces files compiled by a build step
    Contraindication: tasks that produce no build artefacts
                      (config-only tasks, documentation tasks)

Seed this pattern for every project regardless of stack.


### Category 2 — Environment patterns

Patterns about how to correctly configure and verify the environment.
These prevent environment contract mismatches during Z0-2 and
EnvironmentReviewer failures during QA.

Derive these from the environment contract directly.
Every deployment.provider and framework.output_mode combination
should have a pattern.


### Category 3 — Stack conventions

Patterns about how to use the declared tech stack correctly in
this project's context. These are what TaskPerformer and
ProofDesigner benefit from most.

Derive these from tech_stack in the project manifest.
Apply the stack knowledge tables in Part 3 of this skill.


### Category 4 — Project-specific patterns

Patterns that arise from the project's specific constraints
(from project_manifest.constraints). Only seed these if the
constraint is non-obvious and an agent would benefit from
knowing the correct approach.

  Example: constraint "no third-party form service" →
  pattern for Netlify Forms native HTML integration


---


## Part 3 — Stack Knowledge Tables

Use these when the corresponding technology appears in the manifest.
These are starting points — populate the pattern schema fully for
each entry. Do not copy these verbatim; expand them.


### AstroJS

  Pattern: astro-component-colocation
    Problem: Where to put components relative to pages in an
             Astro project to maintain clarity as the project grows.
    Approach: Page-specific components in src/components/[page-name]/;
              shared components in src/components/shared/;
              layout components in src/layouts/
    Evidence: AstroJS project structure conventions
    Contraindication: Single-page projects where colocation adds
                      complexity without benefit

  Pattern: astro-static-output-netlify
    Problem: AstroJS output mode must match the Netlify adapter
             configuration or deployments silently fail.
    Approach: Set `output: 'static'` in astro.config.mjs;
              add @astrojs/netlify adapter only if using SSR;
              for static sites, no adapter is needed.
    Evidence: AstroJS and Netlify adapter documentation
    Contraindication: Projects using SSR or hybrid rendering

  Pattern: astro-image-component
    Problem: Using <img> tags directly bypasses Astro's image
             optimisation and hurts Lighthouse performance scores.
    Approach: Use Astro's built-in <Image> component from
              'astro:assets' for all images. Use <Picture> for
              art direction. Reserve <img> for purely decorative
              images with empty alt attributes.
    Evidence: AstroJS image optimisation documentation;
              Lighthouse CLS and LCP metrics
    Contraindication: SVG icons inlined as components;
                      images loaded dynamically at runtime

  Pattern: astro-content-collections
    Problem: Unstructured markdown files in src/pages produce
             no type safety and are hard to query.
    Approach: Use Astro content collections (src/content/)
              with a Zod schema defined in src/content/config.ts
              for any structured content (blog posts, FAQs, etc.)
    Evidence: AstroJS content collections documentation
    Contraindication: Single static pages with no repeated
                      content structure


### Tailwind CSS

  Pattern: tailwind-cn-utility
    Problem: Conditional class names in components produce
             difficult-to-read string concatenation.
    Approach: Use `cn()` utility (clsx + tailwind-merge) for
              all conditional class name composition.
              Import from a shared lib/utils.ts file.
    Evidence: Tailwind CSS ecosystem convention; prevents
              class deduplication issues with tailwind-merge
    Contraindication: Static class names with no conditionals
                      (direct template literal is fine)

  Pattern: tailwind-no-inline-styles
    Problem: Inline style attributes bypass Tailwind and produce
             inconsistent styling that cannot be purged.
    Approach: All styles through Tailwind utility classes.
              For dynamic values that cannot be expressed as
              utilities, use CSS custom properties in a
              <style> block, not inline style attributes.
    Evidence: Tailwind CSS documentation; PurgeCSS behaviour
    Contraindication: Third-party component libraries that
                      require inline styles for functionality


### Netlify

  Pattern: netlify-forms-native
    Problem: Contact forms require a backend to receive submissions,
             but the project has no backend.
    Approach: Add `netlify` attribute to the HTML <form> element
              and `data-netlify="true"`. Add a hidden input with
              name="form-name". Form submissions go to Netlify
              Forms dashboard. No JavaScript required for basic
              submission.
    Evidence: Netlify Forms documentation
    Contraindication: Forms requiring custom validation logic,
                      file uploads, or immediate programmatic
                      response handling

  Pattern: netlify-deploy-previews
    Problem: Verifying changes before merging to main requires
             a staging environment.
    Approach: Netlify automatically creates a deploy preview URL
              for every pull request. Use this URL as the
              staging_url in the environment contract.
              Format: deploy-preview-[PR-number]--[site-name].netlify.app
    Evidence: Netlify deploy preview documentation
    Contraindication: Projects where PRs should not trigger
                      automatic builds (private repos with cost concerns)


---


## Part 4 — Minimum Viable Seed Set

Zone 0 is not complete without at least 5 CANDIDATE patterns.
BootstrapValidator checks this. Aim for this composition:

  1 meta-pattern      (proof evidence format for this stack)
  1–2 env patterns    (deployment configuration)
  2–3 stack patterns  (most impactful conventions for declared stack)

If the declared tech stack is unfamiliar (not in Part 3):
  - Seed the meta-pattern (always applicable)
  - Seed one environment pattern based on the deployment provider
  - Raise uncertainty to FrameworkOwner: "Stack [X] has no
    seeded patterns in skill knowledge base — manual seeding
    required for stack conventions"
  - Do not invent patterns for unfamiliar stacks


---


## Part 5 — What Not to Seed

These are common mistakes. Reject these pattern types before
writing them:

  Principles disguised as patterns
    "Always write clean, readable code"
    "Follow the single responsibility principle"
    → These are not patterns. They have no contraindications
      and no specific applicability. Discard.

  Task-specific notes
    "In this project, the contact form ID is X"
    "Pete prefers components named in PascalCase"
    → These are project notes or task retro entries.
      They belong in open_questions or task retros, not the
      pattern library.

  Version pinning as a pattern
    "Use React 18.3.1 exactly"
    → This is an environment contract entry, not a pattern.

  Instruction sequences
    "Step 1: create the file. Step 2: add the import. Step 3..."
    → This is a task spec, not a pattern. Patterns describe
      an approach, not a procedure.

  Unsubstantiated opinions
    "This approach is better because it feels cleaner"
    → No evidence basis. Discard.


---


## Self-Check Before Submitting

  [ ] All entries have all required schema fields
  [ ] Every entry has at least one contraindication
  [ ] No entry has "none" as its only contraindication
  [ ] Every evidence field names a source type
  [ ] No invented patterns for unfamiliar stacks
  [ ] At least one meta-pattern is included
  [ ] Total CANDIDATE count ≥ 5
  [ ] All entries are status: CANDIDATE (never self-promote)
  [ ] No principles, task notes, or instruction sequences
      have been formatted as patterns