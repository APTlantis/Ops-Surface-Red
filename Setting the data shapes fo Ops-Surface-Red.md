# Setting the data shapes fo Ops-Surface-Red


I’d make one architectural decision first:

## One shared object envelope, six typed payloads

Every record gets the same universal shell:

```text
Object
├─ identity
│  ├─ id
│  ├─ type
│  ├─ name
│  ├─ acronym / short_name
│  └─ summary
│
├─ operational state
│  ├─ attention
│  ├─ pinned
│  ├─ status
│  └─ lifecycle
│
├─ location
│  ├─ canonical_path / target
│  └─ repository / URI, when applicable
│
├─ relationships[]
│
├─ artifacts[]
│
├─ tags[]
│
└─ payload
   └─ TYPE-SPECIFIC DATA
```

That means your current right-hand editor is already most of the **shared envelope**.

Then the six pages only need to solve one question:

> What additional information makes this kind of object operationally useful?

I would **not** let every type grow 30 fields. Most of the page should stay compact.

---

# 1. `project`

This is the richest object type, but even here I’d resist turning it into project-management software.

### Purpose

Represents something being built, maintained, researched, or operated.

### Structure

```text
PROJECT
├─ Core
│  ├─ name
│  ├─ summary
│  ├─ status
│  ├─ lifecycle
│  └─ canonical path
│
├─ Project State
│  ├─ version
│  ├─ completion
│  ├─ current phase
│  ├─ next action
│  └─ blocker
│
├─ Authorities
│  ├─ PPS
│  ├─ governing standards
│  └─ manifest
│
├─ Execution
│  ├─ operators
│  └─ AI workflows
│
├─ Outputs
│  └─ artifacts
│
└─ Relationships
```

### Typed payload

```toml
[payload]
version = ""
completion = 0
phase = ""
next_action = ""
blocker = ""
manifest = ""
repository = ""
```

I would keep **completion optional**. Some projects have meaningful percentages; others absolutely do not.

### Main project page

Visually:

```text
┌ PROJECT ──────────────────────────────┐
│ Wayfinder                    current │
│ Workspace hygiene / cleanup runner   │
├──────────────────────────────────────┤
│ Version       0.2.0                  │
│ Completion    84%                    │
│ Phase         Operational hardening  │
│ Next action   Fix remaining findings │
│ Blocker       —                      │
├──────────────────────────────────────┤
│ GOVERNED BY                          │
│ WGS • PPS                            │
│                                     │
│ OPERATED BY                          │
│ Wayfinder Runner                    │
│                                     │
│ WORKFLOWS                            │
│ Wayfinder → Codex Fix Loop           │
│                                     │
│ ARTIFACTS                            │
│ Discover report • Manifest • ...     │
└──────────────────────────────────────┘
```

---

# 2. `powershell-operator`

This one should represent a **bounded operational capability**, not merely a `.ps1` file.

That distinction is important.

### Purpose

A callable PowerShell operation that Ops knows exists and understands enough to expose safely.

### Structure

```text
POWERSHELL OPERATOR
├─ Core
│
├─ Invocation
│  ├─ script
│  ├─ entry point
│  ├─ working directory
│  └─ parameters
│
├─ Safety
│  ├─ privilege requirement
│  ├─ mutation level
│  ├─ preview supported
│  └─ confirmation required
│
├─ Contract
│  ├─ inputs
│  ├─ outputs
│  ├─ exit behavior
│  └─ timeout
│
├─ Targets
│  └─ projects / stock / artifacts
│
└─ Relationships
```

### Typed payload

```toml
[payload]
script = ""
entry_point = ""
working_directory = ""

privilege = "user"       # user | admin
mutation = "read"        # read | bounded-write | destructive
preview_supported = true
confirmation_required = false

timeout_seconds = 300
```

Parameters should probably become their own structured child collection:

```toml
[[payload.parameters]]
name = "ProjectPath"
type = "path"
required = true
```

This is what eventually gives you your **bounded operation previews** without redesigning this object later.

---

# 3. `city-hall`

I would define this as:

> **An authoritative governance or standards object supplied by City Hall.**

Not “anything related to City Hall.”

That keeps it useful.

### Purpose

Represents standards, policies, registries, specifications, and canonical governance authorities.

WGS and PPS are perfect examples.

### Structure

```text
CITY HALL OBJECT
├─ Core
│
├─ Authority
│  ├─ acronym
│  ├─ authority class
│  ├─ version
│  ├─ status
│  └─ canonical source
│
├─ Governance
│  ├─ governs
│  ├─ scope
│  └─ exclusions
│
├─ Implementation
│  ├─ compliance target
│  └─ evidence / artifacts
│
└─ Relationships
```

### Authority class

I’d make this a controlled field:

```text
standard
specification
policy
registry
schema
procedure
```

### Typed payload

```toml
[payload]
authority_class = "standard"
version = ""
scope = ""
canonical_source = ""
```

The key relationship is:

```text
CITY-HALL OBJECT ──governs──▶ OBJECT
```

This page should emphasize **authority**, not operational execution.

---

# 4. `stock`

This one deserves a very deliberate definition.

I’d define stock as:

> **Reusable, known-good material held for future operational use.**

Not an artifact generated by a project.

That gives you a clean distinction:

```text
Artifact = something produced / captured / evidenced
Stock    = something retained for reuse
```

Examples:

* templates
* boilerplate
* reference datasets
* installers
* schemas
* known-good source material
* reusable scripts not exposed as operators
* icons/assets
* snippets
* package material

### Structure

```text
STOCK
├─ Core
│
├─ Classification
│  ├─ stock class
│  ├─ format
│  └─ source
│
├─ Inventory
│  ├─ location
│  ├─ availability
│  ├─ version
│  └─ quantity / size where relevant
│
├─ Trust
│  ├─ provenance
│  ├─ checksum
│  └─ verified
│
├─ Usage
│  ├─ intended use
│  └─ consumers
│
└─ Relationships
```

### Typed payload

```toml
[payload]
stock_class = "reference"
format = ""
source = ""
version = ""
provenance = ""
verified = false
intended_use = ""
```

Suggested stock classes:

```text
reference
template
source
binary
dataset
media
schema
snippet
package
other
```

I’d avoid making that taxonomy too elaborate initially.

---

# 5. `artifact`

This should be the **evidence/output object**.

### Purpose

Represents a concrete output, report, package, release asset, manifest, screenshot, evidence record, or other durable product of activity.

### Structure

```text
ARTIFACT
├─ Core
│
├─ Identity
│  ├─ artifact class
│  ├─ media / format
│  ├─ version
│  └─ path
│
├─ Provenance
│  ├─ produced by
│  ├─ produced at
│  ├─ source object
│  └─ generating operation
│
├─ Integrity
│  ├─ size
│  ├─ hashes
│  └─ signature / verification state
│
├─ Disposition
│  ├─ retained
│  ├─ published
│  └─ canonical
│
└─ Relationships
```

### Typed payload

```toml
[payload]
artifact_class = "report"
format = ""
version = ""
produced_at = ""
size_bytes = 0

canonical = false
published = false
verified = false
```

Hashes should be a child collection, not fixed columns:

```toml
[[payload.hashes]]
algorithm = "sha256"
value = ""
```

That fits your existing provenance philosophy much better than `sha256`, `blake3`, etc. becoming hardcoded schema fields.

### Artifact classes

Something simple:

```text
report
manifest
package
release
evidence
documentation
image
dataset
log
archive
other
```

---

# 6. `ai-workflow`

This is the other one I’d make especially structured.

An AI workflow is **not an agent** and not merely a prompt.

It is:

> A defined sequence in which AI participates in an operational process.

So:

```text
"Run Wayfinder, report to Codex, fix findings, rerun"
```

is one workflow.

### Structure

```text
AI WORKFLOW
├─ Core
│
├─ Trigger
│  ├─ manual / scheduled / event
│  └─ starting object
│
├─ Execution
│  ├─ steps
│  ├─ model role
│  ├─ tools/operators
│  └─ inputs
│
├─ Controls
│  ├─ autonomy
│  ├─ write scope
│  ├─ approval boundary
│  └─ stop condition
│
├─ Output
│  ├─ result type
│  └─ artifacts produced
│
└─ Relationships
```

### Typed payload

```toml
[payload]
trigger = "manual"
autonomy = "assisted"
write_scope = "bounded"
approval_required = false
stop_condition = ""
```

And then workflow steps:

```toml
[[payload.steps]]
order = 1
kind = "operator"
target = "wayfinder-run"

[[payload.steps]]
order = 2
kind = "ai"
role = "analyze-findings"

[[payload.steps]]
order = 3
kind = "ai"
role = "apply-bounded-fixes"

[[payload.steps]]
order = 4
kind = "operator"
target = "wayfinder-run"
```

This structure buys you a *lot* later.

---

# The six objects together

I think this is the clean conceptual model:

```text
                        ┌───────────────┐
                        │   CITY HALL   │
                        │   authority   │
                        └───────┬───────┘
                                │ governs
                                ▼
┌────────────┐          ┌───────────────┐
│   STOCK    │─────────▶│    PROJECT    │
│ reusable   │ consumes │ active work   │
└────────────┘          └───────┬───────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
                    ▼           ▼           ▼
             ┌────────────┐ ┌─────────┐ ┌────────────┐
             │ POWERSHELL │ │   AI    │ │  ARTIFACT  │
             │  OPERATOR  │ │WORKFLOW │ │   output   │
             └────────────┘ └─────────┘ └────────────┘
                 executes       directs       records
```

That taxonomy actually has very little overlap.

---

## And I would standardize these relationships now

This will save you a pile of pain later.

```text
governs
implements
contains
depends-on
produces
produced-by
consumes
used-by
operates-on
executed-by
invokes
part-of
references
supersedes
derived-from
validates
```

You absolutely do **not** need all of them visible in every editor. They’re just your canonical relationship vocabulary.

---

# Page architecture

I also would **not build six totally independent forms**.

I’d make them all follow this exact rhythm:

```text
┌─────────────────────────────────────────┐
│ TYPE / IDENTITY                         │
│ shared envelope                         │
├─────────────────────────────────────────┤
│ TYPE-SPECIFIC PAYLOAD                   │
│ only fields meaningful to this type     │
├─────────────────────────────────────────┤
│ RELATIONSHIPS                           │
│ incoming + outgoing                     │
├─────────────────────────────────────────┤
│ ARTIFACTS / REFERENCES                  │
│ where appropriate                       │
├─────────────────────────────────────────┤
│ OPERATIONAL ACTIONS                     │
│ if this object supports them            │
└─────────────────────────────────────────┘
```

So the user learns **one Ops object page**, not six applications.

And your implementation effectively becomes:

```text
ObjectEditor
    +
PayloadEditor<ProjectPayload>

ObjectEditor
    +
PayloadEditor<OperatorPayload>

ObjectEditor
    +
PayloadEditor<CityHallPayload>
...
```

That is the point where I’d freeze the object model.

The six types then have very crisp meanings:

| Type                    | Meaning                                 |
| ----------------------- | --------------------------------------- |
| **project**             | Work being undertaken                   |
| **powershell-operator** | Bounded executable capability           |
| **city-hall**           | Governing authority                     |
| **stock**               | Reusable known material                 |
| **artifact**            | Durable output/evidence                 |
| **ai-workflow**         | Defined AI-assisted operational process |

That feels tight enough to build against without boxing Ops into some giant enterprise ontology later.
