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
- transparent local persistence
- Windows path launching

Runtime verification is pending because this workspace does not contain the Windows Red/View toolchain. The project deliberately makes no build or release claim yet.

## Persistence

`data/ops-state.red` is the v0.1 system of record. It contains scalar values and nested Red blocks and is loaded as data rather than executed as code.

Record deletion removes the operational record and its relationship records. It never deletes a referenced filesystem target. Preserve the data file across source updates.

## Historical scaffold

The surviving Tauri frontend was moved to `legacy/tauri-scaffold/`. It is excluded from the active architecture and build. The supplied archive did not include the Rust backend described by the old documents, so earlier Rust and SQLite behavior is not reproducible from this package.

## Next verification

On the Windows host:

1. Install or expose `red.exe` on `PATH`.
2. Run `run-red.cmd`.
3. Exercise create, edit, search, pin, board move, delete, and path-opening behavior.
4. Close and reopen the app and confirm state persistence.
5. Run `build-red.cmd` and launch `dist\Aptlantis-Ops.exe`.
6. Record failures without promoting static inspection into runtime evidence.

