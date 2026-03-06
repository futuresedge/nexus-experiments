# Skill: Environment Contract Writing

TRIGGERS: "write environment contract", "environment contract",
          "create env contract", "document the environment"
PHASE:    Zone 0 — Task Z0-2
USED BY:  EnvironmentContractAuthor


## What this skill does

Writes a complete, internally consistent, and verifiable environment
contract from the project manifest's tech stack and deployment
declarations. The environment contract is the canonical truth about
the project's technical environment — every agent that touches the
environment references this document.

"Verifiable" is the operative word. Every field must describe
something that can be independently confirmed. A field that cannot
be checked is not a field — it is an aspiration.


## The Verifiability Rule

For every field you write, ask:
  "Can someone run a command or open a file and confirm this?"

  VERIFIABLE:   "build command: pnpm build"
                (run it — exit code 0 confirms it)
  VERIFIABLE:   "Node version: 22.x"
                (run `node --version` — confirms it)
  NOT VERIFIABLE: "fast build times"
                (what command confirms this? there is none)
  NOT VERIFIABLE: "production-ready configuration"
                (meaningless — cannot be confirmed)

If a field cannot be made verifiable, raise uncertainty to
human:director. Do not write an unverifiable field.


---


## Part 1 — Contract Schema

Fields are organised by stack type. Every contract includes the
UNIVERSAL section. Then include the section(s) matching the
project's stack type. Omit sections that do not apply.


### UNIVERSAL — required for all projects

```
project_id:      [from project manifest — must match exactly]
contract_version: 1.0
last_updated:    [ISO 8601]
reviewed_by:     EnvironmentReviewer
review_status:   PENDING | APPROVED

runtime:
  name:            [Node | Python | Ruby | other]
  version:         [exact version or minimum version]
  version_command: [command to verify: e.g. "node --version"]
  package_manager: [npm | pnpm | yarn | pip | other]
  install_command: [e.g. "pnpm install"]

repository:
  vcs:             [git]
  branch_strategy: [e.g. "feature branches off main"]
  main_branch:     [main | master | other]

development:
  os:              [macOS | Linux | Windows | any]
  editor:          [VS Code | other | not specified]
  start_command:   [command to start local dev server]
  local_port:      [e.g. 4321]
  build_command:   [command to build for production]
  build_output:    [output directory: e.g. "dist/"]

verification:
  local_check:     [command or steps to verify local build]
  deployed_check:  [command or steps to verify deployed build]
```


### STATIC SITE — include when stack uses AstroJS, Next.js static,
                  Eleventy, Hugo, Jekyll, or similar

```
framework:
  name:            [e.g. AstroJS]
  version:         [exact or minimum]
  config_file:     [e.g. "astro.config.mjs"]
  output_mode:     [static | server | hybrid]

styling:
  name:            [Tailwind CSS | CSS Modules | SCSS | other]
  version:         [exact or minimum]
  config_file:     [e.g. "tailwind.config.mjs"]

content:
  strategy:        [file-based | CMS | headless CMS | none]
  cms:             [name if applicable | none]
```


### DEPLOYMENT — include for all projects

```
deployment:
  provider:        [Netlify | Vercel | GitHub Pages | AWS | other]
  deploy_trigger:  [git push to main | manual | CI workflow]
  production_url:  [https://... or "not yet assigned"]
  staging_url:     [https://... or "not configured"]
  build_command:   [as used by deploy provider — may differ from
                    local build_command]
  publish_dir:     [directory provider deploys from: e.g. "dist"]
  env_vars:        [list of required environment variable names —
                    names only, never values]
```


### FORMS / SERVICES — include when project uses third-party services

```
services:
  - name:          [e.g. Netlify Forms]
    type:          [forms | analytics | auth | payments | other]
    integration:   [how integrated: e.g. "HTML form attribute"]
    requires_env:  [env var name if any]
    local_mock:    [true | false — can it be used locally?]
```


### PERFORMANCE — include when constraints declare performance targets

```
performance:
  targets:
    - metric:      [e.g. Lighthouse Performance]
      threshold:   [e.g. ≥ 90]
      tool:        [e.g. "lighthouse CLI"]
      command:     [exact command to measure]
```


---


## Part 2 — Deriving Fields from the Manifest

Work through the manifest fields in this order:

### From tech_stack

For each technology declared:
1. Identify which schema section it belongs to
2. Populate that section's fields
3. Flag any field where the version was not specified in the manifest
   → add to contract open_questions, do not invent a version

  "AstroJS 5.x"      → framework.name: AstroJS,
                        framework.version: 5.x
  "AstroJS"          → framework.name: AstroJS,
                        framework.version: "not specified"
                        open_question: "AstroJS version required
                        for reproducible environment"
  "Tailwind CSS 4"   → styling.name: Tailwind CSS,
                        styling.version: 4
  "Netlify"          → deployment.provider: Netlify


### From deployment

  Provider name      → deployment.provider
  Target URL         → deployment.production_url
  Staging URL        → deployment.staging_url
  If URL not given   → record as "not yet assigned" — do not invent


### From constraints

Constraints map to specific contract fields:

  "no React"         → add to contract: constraints list
                       (this is a TemplateAuthor note — TaskPerformer
                        must not introduce React components)
  "Lighthouse ≥ 90"  → performance.targets entry
  "no third-party
   form service"     → services: none; note constraint explicitly


---


## Part 3 — Fields That Always Require Raising Uncertainty

These fields cannot be derived — they require information not
available from the manifest. Raise uncertainty if missing:

  runtime.version_command
    If the runtime version was not declared in the manifest,
    what version should be used? This is not derivable.

  development.local_port
    AstroJS defaults to 4321, but if overridden in config,
    the contract will be wrong. Raise uncertainty if not stated.

  deployment.env_vars
    Environment variable names must be declared explicitly.
    Never invent variable names. If services are declared but
    no env vars specified, raise: "What env var names does
    [service] require?"

  deployment.production_url
    Record "not yet assigned" if not provided — do not guess.

  framework.output_mode (static sites)
    For AstroJS: static, server, or hybrid.
    The choice affects how Netlify deploys it.
    Default is static — but record the assumption in
    open_questions if not explicitly stated.


---


## Part 4 — Internal Consistency Checks

Before submitting, check every cross-reference in the contract:

  build_command consistency
    development.build_command and deployment.build_command
    should match unless the project uses different commands
    for local and deployed builds. If they differ, document why.

  publish_dir consistency
    deployment.publish_dir must match framework.output or
    development.build_output. If they differ, the deploy
    provider will deploy the wrong directory.

  env_vars completeness
    Every service in services[] that has requires_env
    must have a corresponding entry in deployment.env_vars.
    If a service requires an env var that isn't listed,
    the deployment will silently fail.

  verification commands
    Every command in verification.local_check must use
    commands that exist in the declared tech stack.
    Do not write verification steps using tools not in the stack.


---


## Part 5 — Open Questions Format

Add to the contract's open_questions section using this format:

```
open_questions:
  - field:   [contract field path e.g. "runtime.version"]
    gap:     [what is missing or ambiguous]
    impact:  [what fails downstream if not resolved]
    resolve: [what specific information resolves it]
```

Open questions do not block submission. EnvironmentReviewer
reviews the contract including its open questions. Unresolved
open questions that affect verifiability will result in a FAIL
verdict from EnvironmentReviewer.


---


## Self-Check Before Submitting

  [ ] project_id matches project manifest exactly
  [ ] runtime section is complete with version_command
  [ ] build_command produces output in a declared output directory
  [ ] deployment.publish_dir matches the build output directory
  [ ] Every service with requires_env has an env_vars entry
  [ ] No invented values — every field traces to manifest or
      a named default with an open_question flagging the assumption
  [ ] verification section describes commands, not outcomes
      ("run pnpm build" not "ensure build succeeds")
  [ ] All performance targets have a measurement command
  [ ] review_status is PENDING (EnvironmentReviewer sets APPROVED)
  [ ] No unverifiable fields remain without an open_question