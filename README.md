# Ops Surface Red

Aptlantis Ops is a native Red/View desktop control surface for the projects, governance documents, operators, stock material, artifacts, and bounded AI workflows that currently matter across Aptlantis.

It is designed around operational attention rather than conventional scheduling:

> What deserves attention now, and what can I do about it from here?

## Why Red

Red makes the interface, data model, and small operational behaviors part of one compact native program. The project no longer maintains parallel browser and desktop implementations or a Node/Rust build chain.

## Run

Install the Windows Red/View toolchain and ensure `red.exe` is available on `PATH`, then use:

```bat
run-red.cmd
```

Or invoke the source directly:

```bat
red.exe main.red
```

## Build

```bat
build-red.cmd
```

The expected output is `dist\Aptlantis-Ops.exe`.

## First-shell capabilities

- Switch between primary and secondary boards.
- Select operational lanes.
- Search the selected lane by name, summary, or tags.
- Create a new record in the current lane with a lane-appropriate object type.
- Inspect and edit common object fields.
- Edit a compact type-specific payload block for each object type.
- Pin an object as surfaced attention.
- Move a record to the other board.
- Open a recorded path with Windows Explorer.
- Delete a record and its relationships without deleting filesystem content.
- Persist objects and relationships in `data/ops-state.red`.

Relationship creation is guided by the canonical vocabulary: `governs`, `implements`, `contains`, `depends-on`, `produces`, `produced-by`, `consumes`, `used-by`, `operates-on`, `executed-by`, `invokes`, `part-of`, `references`, `supersedes`, `derived-from`, and `validates`.

## Object Types

The retained vocabulary is `project`, `powershell-operator`, `city-hall`, `stock`, `artifact`, and `ai-workflow`. Every object has the same shared envelope and a compact typed payload block:

- `project`: work being undertaken.
- `powershell-operator`: bounded executable capability.
- `city-hall`: governing authority.
- `stock`: reusable known material.
- `artifact`: durable output or evidence.
- `ai-workflow`: defined AI-assisted operational process.

## Project structure

```text
main.red                         entry point
src/ops-control.red              model, persistence, operations, and Red/View UI
data/ops-state.red               transparent local state
assets/project-icons/            retained project artwork
legacy/tauri-scaffold/           superseded, non-authoritative frontend source
AGENTS.md                        modification and verification rules
Project-Proposal.md              authoritative scope
Ops Control Surface.manifest.toml canonical machine-readable project metadata
```

## Safety rules

- Boards are projections; the stored records are authoritative.
- Relationships remain separate records.
- Record deletion never deletes a filesystem target.
- External mutation requires a future operation contract, preview, and confirmation.
- Runtime and release claims require Windows-host evidence.
