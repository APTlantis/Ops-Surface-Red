# Ops Control Surface Project Proposal

## Project Type

Native Windows desktop application written in Red.

## Responsibility Posture

Shared.

## Readiness Level

Implementation reboot in progress.

## Governing Standards

- Proposal: PPS
- Workspace: WGS
- Delivery: DRS

## Problem Statement

Aptlantis project, operator, reference, artifact, governance, and workflow records move through intake, zoning, promotion, release, and maintenance. Without a focused local operations surface, those records are difficult to inspect, relate, and act upon without reconstructing procedures from memory.

## Mission

Ops Control Surface provides a local-first operational environment for typed Aptlantis objects, their relationships, and bounded operations. It answers two questions: **what deserves attention now, and what can be done about it from here?**

The application is not a general project manager. The database remembers what exists; schemas describe what those things are; relationships explain why they matter; operations preserve how work gets done; boards surface what matters now.

## Architecture Decision

The active implementation is a native Red/View application.

- Red/View owns the desktop interface.
- Red blocks express typed operational records and first-class relationships.
- A transparent local Red data file is the v0.1 system of record.
- Boards and inspectors are projections of that stored state.
- Windows shell integration opens recorded paths and will later launch bounded operations.
- No browser-preview implementation exists or needs to remain behaviorally aligned.

The superseded React/TypeScript/Vite/Tauri scaffold is retained only as historical reference under `legacy/tauri-scaffold/`. It is not an active implementation dependency.

## In Scope

- Typed operational object registry.
- Project, PowerShell operator, City Hall, stock/reference, artifact, and AI-workflow objects.
- Separate relationship records.
- Primary and secondary attention boards with meaningful lanes.
- Search, create, inspect, edit, move, pin, and delete-record behavior.
- Transparent local persistence with recoverable seed state.
- Opening recorded local paths through the Windows shell.
- Schema-driven, type-specific inspectors as the model matures.
- Managed artifact intake that preserves copied files when records are deleted.
- Explicitly bounded operator execution with preview and confirmation.

## Out of Scope Unless Refreshed

- Cloud operations dashboard or collaboration service.
- Generic project-management features added by convention.
- Automatic project promotion or destructive cleanup.
- Autonomous AI decision-making.
- Silent inference of authoritative metadata.
- Treating historical or generated build output as governed release evidence.
- Release-readiness claims before native launch, persistence, compiled executable, installer, and hash evidence exist.

## Success Criteria

- [x] The active source tree has no Node, React, Rust, Vite, Tauri, or SQLite runtime dependency.
- [x] Typed objects and relationships have independent, inspectable representations.
- [x] A native Red/View shell implements board/lane navigation, search, create, edit, move, pin, delete-record, persistence, and path-opening flows in source.
- [ ] The shell launches successfully with the Windows Red/View interpreter.
- [ ] State survives a close-and-reopen smoke test.
- [x] Every object type exposes a compact type-specific payload block in the inspector.
- [ ] Typed payload validation, schema versioning, and migration backups are hardened.
- [ ] Relationships can be created, inspected, and removed through the interface.
- [ ] Managed artifacts can be copied, linked, and retained according to policy.
- [ ] Operator execution shows command, working directory, elevation, mutation, and expected output before launch.
- [ ] A compiled Windows executable passes the defined smoke suite.

## Failure Criteria

- Relationship state becomes embedded only in cards.
- Deleting an artifact record deletes the referenced or managed file.
- An external mutation executes without explicit operator review.
- Boards become authoritative storage rather than attention projections.
- Generated metadata is presented as authoritative without operator confirmation.
- Static inspection is represented as runtime or release verification.

## Constraints

- Technical: Red and Red/View; Windows-first; local data remains human-inspectable.
- Scope: local Aptlantis operations and governance object tracking.
- Data: objects, relationships, and artifact references must remain recoverable.
- Safety: filesystem deletion is never implied by record deletion.
- Distribution: a public Windows GUI release defaults to Microsoft Store MSIX unless a documented exception is approved.

## Risks and Mitigations

- **Red remains a comparatively small ecosystem.** Keep the v0.1 dependency surface inside Red/View and the Windows shell; add external bindings only to solve demonstrated needs.
- **A fixed-position persistence schema can become brittle.** Version the schema and migrate to named records before type-specific payloads expand materially.
- **The app could drift into generic project management.** Require every feature to remove real Aptlantis operational friction or preserve otherwise-lost knowledge.
- **Build success could be mistaken for release readiness.** Keep interpreter, compiled executable, packaging, installer, and evidence gates separate.

## Roadmap

1. Run and correct the native shell against the installed Windows Red/View toolchain.
2. Verify CRUD, search, movement, deletion, persistence, and path launching.
3. Harden the compact common record and typed payload blocks with schema versioning, validation, and migration backups.
4. Add first-class relationship editing and impact queries.
5. Add managed artifact intake and preserve-file deletion tests.
6. Add bounded PowerShell operation previews and execution history.
7. Compile and evaluate the Windows executable and distribution posture.

## Version Milestones

### v0.1.0 — Native control shell

Board/lane navigation, transparent persistence, common object CRUD, search, pinning, board movement, relationship storage, and path launching are verified on Windows.

### v0.2.0 — Typed operations

Type-specific inspectors, relationship management, managed artifact intake, and bounded PowerShell execution are verified.

### v0.3.0 — Operational hardening

Migration handling, backups, import/export, compiled packaging, and release posture are proven with durable evidence.
