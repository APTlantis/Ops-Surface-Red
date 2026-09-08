# Ops Surface — Authoritative Object Model

## 1. Purpose

This document defines the authoritative object structure for **Ops Surface**.

Ops Surface represents operational information through a common object model composed of:

- one universal object envelope;
- six first-class object types;
- type-specific payloads;
- a controlled relationship vocabulary;
- a consistent object-page architecture;
- deterministic rules for object creation, editing, and type changes.

The goal is not to create a large enterprise ontology or general-purpose project-management system.

The goal is to establish a small, durable operational model that Ops Surface can build against without repeatedly redefining what its records mean.

---

# 2. Core Architecture

## 2.1 Universal Object Envelope

Every first-class Ops Surface record is an **Object**.

All objects share the same outer structure regardless of type.

```text
Object
├─ Identity
│  ├─ id
│  ├─ type
│  ├─ name
│  ├─ acronym / short_name
│  └─ summary
│
├─ Operational State
│  ├─ attention
│  ├─ pinned
│  ├─ status
│  └─ lifecycle
│
├─ Location
│  ├─ canonical_path / target
│  └─ repository / URI, when applicable
│
├─ relationships[]
├─ artifacts[]
├─ tags[]
│
└─ payload
   └─ TYPE-SPECIFIC DATA
```

The shared envelope carries information that has the same meaning across object types.

The `payload` contains only information specific to the object's declared type.

### Governing invariant

> **An object's payload must always conform to its current type.**

The shared envelope is stable across type changes.

The typed payload is not.

---

# 3. Authoritative Object Types

Ops Surface recognizes six first-class object types.

| Type | Authoritative meaning |
|---|---|
| `project` | Work being undertaken |
| `powershell-operator` | Bounded executable capability |
| `city-hall` | Governing authority |
| `stock` | Reusable known material |
| `artifact` | Durable output or evidence |
| `ai-workflow` | Defined AI-assisted operational process |

These definitions are semantic boundaries, not merely UI categories.

Objects should be assigned according to what they **are operationally**, not according to file format, source application, or where they happen to be stored.

---

# 4. System Model

```text
                         ┌────────────────┐
                         │   CITY HALL    │
                         │   authority    │
                         └───────┬────────┘
                                 │ governs
                                 ▼
┌─────────────┐          ┌────────────────┐
│    STOCK    │─────────▶│    PROJECT     │
│  reusable   │ consumes │  active work   │
└─────────────┘          └───────┬────────┘
                                 │
                     ┌───────────┼───────────┐
                     │           │           │
                     ▼           ▼           ▼
              ┌────────────┐ ┌───────────┐ ┌────────────┐
              │ POWERSHELL │ │    AI     │ │  ARTIFACT  │
              │  OPERATOR  │ │ WORKFLOW  │ │   output   │
              └────────────┘ └───────────┘ └────────────┘
                  executes       directs       records
```

The model separates six operational concerns:

```text
Authority     → City Hall
Work          → Project
Capability    → PowerShell Operator
Process       → AI Workflow
Input/reuse   → Stock
Output        → Artifact
```

This separation is deliberate.

---

# 5. `project`

## Definition

A `project` represents something being built, maintained, researched, or operated.

It is the primary representation of active work.

A project is **not** intended to become a complete project-management system.

## Structure

```text
PROJECT
├─ Core
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

## Typed Payload

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

`completion` is optional.

Percentage completion should only be used where a meaningful percentage exists.

## Operational emphasis

The project page should answer:

```text
What is this?
Where is it?
What state is it in?
What governs it?
What operates on it?
What happens next?
What has it produced?
```

---

# 6. `powershell-operator`

## Definition

A `powershell-operator` represents a **bounded operational capability exposed through PowerShell**.

It does not merely represent a `.ps1` file.

An operator is something Ops Surface understands sufficiently to expose, invoke, constrain, and eventually preview safely.

## Structure

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

## Typed Payload

```toml
[payload]
script = ""
entry_point = ""
working_directory = ""

privilege = "user"
mutation = "read"
preview_supported = true
confirmation_required = false

timeout_seconds = 300
```

Controlled values:

```text
privilege:
  user
  admin

mutation:
  read
  bounded-write
  destructive
```

## Parameters

Parameters are structured children of the operator payload.

```toml
[[payload.parameters]]
name = "ProjectPath"
type = "path"
required = true
```

This structure is the foundation for bounded execution and operation-preview functionality.

---

# 7. `city-hall`

## Definition

A `city-hall` object represents an **authoritative governance or standards object supplied by City Hall**.

It does not mean anything merely associated with the City Hall project.

Examples include:

- WGS;
- PPS;
- standards;
- specifications;
- policies;
- registries;
- schemas;
- procedures.

## Structure

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

## Authority Classes

```text
standard
specification
policy
registry
schema
procedure
```

## Typed Payload

```toml
[payload]
authority_class = "standard"
version = ""
scope = ""
canonical_source = ""
```

## Primary relationship

```text
CITY-HALL OBJECT ──governs──▶ OBJECT
```

The City Hall object page emphasizes **authority and governance**, not execution.

---

# 8. `stock`

## Definition

`stock` represents **reusable, known material retained for future operational use**.

Stock is not merely stored data.

Its defining characteristic is intended reuse.

Examples include:

- templates;
- boilerplate;
- reference datasets;
- installers;
- schemas;
- known-good source material;
- reusable scripts not exposed as operators;
- icons and media;
- snippets;
- package material.

## Stock versus Artifact

This distinction is authoritative:

```text
ARTIFACT
Something produced, captured, recorded, or evidenced.

STOCK
Something retained because it is expected to be reused.
```

An artifact may later become stock, but the concepts are not interchangeable.

## Structure

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

## Typed Payload

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

## Stock Classes

Initial controlled vocabulary:

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

The stock taxonomy should remain deliberately small until actual usage demonstrates a need for further subdivision.

---

# 9. `artifact`

## Definition

An `artifact` represents a **durable output, evidence object, or captured product of activity**.

Examples include:

- reports;
- manifests;
- packages;
- release assets;
- evidence records;
- screenshots;
- documentation;
- datasets;
- logs;
- archives.

## Structure

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

## Typed Payload

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

## Hashes

Hashes are represented as a structured collection rather than fixed schema columns.

```toml
[[payload.hashes]]
algorithm = "sha256"
value = ""
```

This allows integrity algorithms to evolve without changing the artifact schema.

## Artifact Classes

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

# 10. `ai-workflow`

## Definition

An `ai-workflow` represents a **defined operational process in which AI participates**.

It is not:

- an AI agent;
- a model;
- a prompt;
- a conversation.

It represents the process itself.

Example:

```text
Run Wayfinder
    ↓
Report findings to Codex
    ↓
Apply bounded fixes
    ↓
Run Wayfinder again
```

That sequence is one AI workflow.

## Structure

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
│  ├─ tools / operators
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

## Typed Payload

```toml
[payload]
trigger = "manual"
autonomy = "assisted"
write_scope = "bounded"
approval_required = false
stop_condition = ""
```

## Workflow Steps

Steps are structured child records.

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

The workflow object describes orchestration.

Operators perform bounded executable actions.

Projects provide work context.

Artifacts record durable outputs.

---

# 11. Canonical Relationship Vocabulary

Relationships are typed.

Ops Surface should use a controlled vocabulary rather than arbitrary free-form relationship names.

Initial canonical vocabulary:

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

Not every relationship must be exposed in every editor.

The vocabulary is canonical at the data-model level; individual object pages may expose only relationships relevant to that type.

---

# 12. Object Page Architecture

Ops Surface does not implement six unrelated object applications.

All object pages follow the same structure.

```text
┌─────────────────────────────────────────┐
│ TYPE / IDENTITY                         │
│ shared envelope                         │
├─────────────────────────────────────────┤
│ TYPE-SPECIFIC PAYLOAD                   │
│ fields meaningful to this object type   │
├─────────────────────────────────────────┤
│ RELATIONSHIPS                           │
│ incoming + outgoing                     │
├─────────────────────────────────────────┤
│ ARTIFACTS / REFERENCES                  │
│ where applicable                        │
├─────────────────────────────────────────┤
│ OPERATIONAL ACTIONS                     │
│ where supported                         │
└─────────────────────────────────────────┘
```

The user learns one Ops Surface object page.

The type changes what appears inside that page.

Conceptually:

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

ObjectEditor
    +
PayloadEditor<StockPayload>

ObjectEditor
    +
PayloadEditor<ArtifactPayload>

ObjectEditor
    +
PayloadEditor<AIWorkflowPayload>
```

---

# 13. Type Authority

The object type is selected from the canonical type set:

```text
project
powershell-operator
city-hall
stock
artifact
ai-workflow
```

Type selection is authoritative.

The UI should not infer type from:

- payload contents;
- path;
- filename;
- current editor contents;
- arbitrary text entry.

The persisted `object/type` is the committed type.

The inspector selection represents a proposed type until Save.

---

# 14. Type Change Semantics

Changing an object's type is a schema transition.

Typed payloads are **not migrated between unrelated types**.

Example:

```text
project
   ↓
artifact
```

The following shared information survives:

```text
id
name
summary
attention
pinned
status
lifecycle
location
relationships
tags
```

The project payload does not survive as an artifact payload.

Instead:

```text
old typed payload
      ↓
   discarded

new object type
      ↓
default payload instantiated
```

This behavior is intentional.

---

# 15. Inspector Behavior

## Existing Object Selected

```text
select object
    ↓
read object/type
    ↓
select matching canonical type
    ↓
render payload editor for that type
    ↓
populate existing payload
```

## Type Changed in Inspector

```text
user selects different type
        ↓
selected type changes
        ↓
render payload editor immediately
        ↓
populate DEFAULT payload for new type
```

The underlying object remains unchanged until Save.

This provides a transactional editing boundary:

```text
Inspector state = proposed edit
Persisted object = committed state
```

Navigating away without saving leaves the object unchanged.

---

# 16. Save Semantics

Save order is authoritative.

```text
1. Determine selected type
2. Determine existing persisted type
3. Compare types
4. Determine payload behavior
5. Parse or instantiate payload
6. Persist object
7. Refresh projection
```

## Same-Type Save

```text
selected type == persisted type
        ↓
parse payload editor
        ↓
save edited typed payload
```

## Changed-Type Save

```text
selected type != persisted type
        ↓
use new-type payload
        ↓
replace previous typed payload
```

The system must never serialize fields belonging to one payload schema into another.

Invalid transition:

```text
PROJECT PAYLOAD
version
completion
phase
next_action
        ↓ type changed
ARTIFACT
        ↓
project fields preserved accidentally
```

This state is prohibited.

---

# 17. New Object Semantics

Creation begins without an assumed type.

```text
New Object
    ↓
clear inspector
    ↓
type = none
    ↓
user explicitly selects type
    ↓
default typed payload appears
    ↓
shared envelope + typed payload edited
    ↓
Save
    ↓
object created
```

`project` should not be automatically selected as the default.

Type is semantically significant enough to require an explicit choice.

---

# 18. Inspector State Matrix

| Event | Type selection | Payload UI | Persisted payload |
|---|---|---|---|
| Select existing object | Existing object type | Existing typed payload | Unchanged |
| Change type | New proposed type | New-type default payload | Unchanged |
| Save same type | Existing type | Edited payload | Updated |
| Save changed type | New type | New-type payload | Replaced |
| Clear inspector | None | Cleared | N/A |
| Create new object | None initially | Appears after type choice | Created on Save |

---

# 19. Required Type Helpers

The implementation should centralize type handling rather than duplicate it across inspector code.

Minimum helpers:

```text
index-of-object-type
selected-object-type
default-payload-for
show-payload-for-type
```

## `index-of-object-type`

Maps the canonical object type name to its UI-list position.

```text
"artifact"
    ↓
index-of-object-type
    ↓
5
```

## `selected-object-type`

Converts the current inspector selection into the canonical type identifier.

## `default-payload-for`

Returns a valid empty/default payload for a specified object type.

```text
default-payload-for "project"
default-payload-for "artifact"
default-payload-for "ai-workflow"
```

## `show-payload-for-type`

Renders the appropriate payload editor and either:

- loads an existing compatible payload; or
- initializes the type's default payload.

---

# 20. Architectural Invariants

The following rules define the stable object model.

### Invariant 1 — One envelope

All first-class objects use the same shared envelope.

### Invariant 2 — Six semantic types

The six canonical types represent different operational concepts, not cosmetic categories.

### Invariant 3 — Typed payload authority

Every payload conforms to its declared object type.

### Invariant 4 — Explicit type selection

Type is selected explicitly and is never inferred from arbitrary payload data.

### Invariant 5 — No implicit cross-type payload migration

Changing type replaces the previous typed payload.

### Invariant 6 — Transactional editing

Inspector changes do not mutate persisted objects until Save.

### Invariant 7 — Controlled relationships

Relationships use a canonical vocabulary.

### Invariant 8 — Shared page rhythm

All six object types use the same overall page architecture.

### Invariant 9 — Compact schemas

Typed payloads contain only information that makes the object operationally useful.

Fields are added because real usage requires them, not because they might someday be useful.

---

# 21. Scope Boundary

This model intentionally does **not** attempt to become:

- a universal knowledge graph;
- a full project-management platform;
- a workflow automation framework;
- an asset-management suite;
- an enterprise CMDB;
- a general ontology engine.

Ops Surface needs enough structure to understand:

```text
what exists
what it means
where it is
what state it is in
what governs it
what it relates to
what can act on it
what consumes it
what it produces
```

The six-object model provides that structure without expanding beyond the operational needs of the application.

---

# 22. Frozen Conceptual Model

```text
                    OPS SURFACE OBJECT

                  ┌───────────────────┐
                  │  SHARED ENVELOPE  │
                  └─────────┬─────────┘
                            │
              ┌─────────────┴─────────────┐
              │                           │
        relationships[]               payload
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    │                     │                     │
                 PROJECT              OPERATOR              CITY HALL
                    │                     │                     │
                  STOCK                ARTIFACT             AI WORKFLOW
```

The shared envelope defines what all Ops objects have in common.

The type defines what the object **is**.

The payload defines what additional information is required to make that type operationally useful.

Relationships define how objects participate in the wider system.

That is the foundation against which the Ops Surface object pages, editors, storage model, and future bounded operations should be built.