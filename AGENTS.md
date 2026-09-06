# Agent Instructions

Read these files before changing the project:

1. `Ops Control Surface.manifest.toml`
2. `Project-Proposal.md`
3. `Project-README.md`
4. `README.md`

## Implementation boundary

- The active implementation is native Red/View.
- `main.red` is the entry point; active application logic belongs under `src/`.
- `data/ops-state.red` is user-owned operational state. Preserve it across code changes.
- Typed objects and relationships remain independent records.
- A board is a projection of stored records, never the system of record.
- Deleting a record must never delete a referenced or managed filesystem artifact.
- Do not restore React, Tauri, Rust, Node, browser-preview, or duplicate persistence paths without a refreshed project proposal.
- Do not infer authoritative metadata merely to fill the interface.
- Operations that mutate external state require an explicit preview and operator confirmation.

## Verification

When a Windows Red/View toolchain is available:

```text
red.exe main.red
red.exe -r -c -o dist\Aptlantis-Ops.exe main.red
```

Smoke-test create, edit, search, board movement, deletion, persistence after restart, and path launching. Never claim runtime or compiled-build verification from static source inspection alone.

