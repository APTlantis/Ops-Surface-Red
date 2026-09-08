# Ops Control Surface

## Purpose and boundary

Ops Control Surface is the governed DRS home for Aptlantis Ops: a local-first, native Windows operations board for typed workspace objects.

It exists to surface operational attention and make useful transitions—open, inspect, edit, launch, package, or verify—nearly frictionless. It is not a general Kanban product, calendar, or collaboration platform.

## Current state

The project was rebooted in Red on 2026-09-05 before the earlier Tauri scaffold accumulated meaningful implementation investment.

The active source is now:

```text
main.red
src/ops-control.red
data/ops-state.red
run-red.cmd
build-red.cmd
```

The first native shell contains source-level implementations for:

- primary and secondary boards
- meaningful board lanes
- typed operational object records
- independent relationship records
- object search and lane filtering
- create, inspect, edit, pin, move, and delete-record flows
- compact type-specific payload editing for the six retained object types
- transparent local persistence
- Windows path launching

The workspace includes `redc.exe`. The native source has compiled successfully to `dist\Aptlantis-Ops.exe`, and bounded launch checks have confirmed that the application process stays live while loading the current state. Full interactive persistence and release verification remain open.

## Persistence

`data/ops-state.red` is the v0.1 system of record. It contains scalar values and nested Red blocks and is loaded as data rather than executed as code. Object records use a shared envelope plus a type-specific payload block; older shared-envelope-only records are normalized in memory when loaded. The next save writes a named schema-v1 state block after validating object records, typed payloads, unique IDs, and relationship endpoints. Migrating the legacy two-block state requires a successful one-time backup at `data/ops-state.red.v0.bak` before the original file is replaced.

Record deletion removes the operational record and its relationship records. It never deletes a referenced filesystem target. Preserve the data file across source updates.

## Historical scaffold

The surviving Tauri frontend was moved to `legacy/tauri-scaffold/`. It is excluded from the active architecture and build. The supplied archive did not include the Rust backend described by the old documents, so earlier Rust and SQLite behavior is not reproducible from this package.

## Next verification

On the Windows host:

1. Run `run-red.cmd` or launch `dist\Aptlantis-Ops.exe`.
2. Exercise create, edit, search, pin, board move, delete, relationship, and path-opening behavior.
3. Save once and confirm `data/ops-state.red.v0.bak` preserves the pre-migration state.
4. Close and reopen the app and confirm schema-v1 state persistence.
5. Record failures without promoting partial smoke checks into release evidence.
