# Getting Started with Ops Surface

Ops Surface is a registry of operational objects, not a task manager or a filesystem organizer. Start by recording a small number of things that already matter, then add relationships as they become useful.

## Your First Session

Begin with one real project that you know well.

1. Open the board and lane where the project should initially appear.
2. Click **New Object**.
3. Select `project` from the Type list. New objects have no assumed type.
4. Fill in the shared fields and the project payload.
5. Click **Save**.
6. Confirm that `data\ops-state.red.v0.bak` now exists. This is the rollback copy made before the older state format is migrated.
7. Close and reopen the app. Confirm that the project and its edited values remain.

After that first save-and-reopen check, continue entering normal records.

## Choose the Lane First

A new object is created in the board and lane currently open when you click **New Object**. Choose that location before beginning the draft.

The primary project lanes mean:

- **Projects / Current**: needs current attention or active decisions.
- **Projects / Maintain**: established work that mainly needs upkeep.
- **Projects / Watch**: worth retaining and monitoring, but not actively worked.

The secondary board is appropriate for broader active, planned, experimental, paused, blocked, or holding work.

Boards and lanes only control where an object is surfaced. They do not determine whether the object exists.

## Entering a Project

Use the shared fields this way:

| Field | What to enter |
| --- | --- |
| Name | The project's exact human-facing name. Required. |
| Acronym | An established short name, if one exists. Do not invent one merely to fill the field. |
| Summary | One or two sentences explaining what the project is and why it matters. |
| Attention | A compact operator-authored signal such as `next`, `current`, `watch`, or `blocked`. |
| Pinned | Enable only when the project should remain visibly surfaced. |
| Path / Target | The canonical local project directory or authoritative target. |
| Tags | A short comma-separated set of useful retrieval terms. |
| Notes | Context that matters operationally but does not belong in the summary or typed payload. |

The project payload is an editable Red property block. Keep every field present, in the displayed order, and keep `completion` numeric:

```red
[
    version "0.1.0"
    completion 35
    phase "Implementation"
    next-action "Verify the first real records after restart"
    blocker ""
    manifest "D:\DRS\Example\Example.toml"
    repository ""
]
```

Use `completion 0` when a meaningful percentage does not exist. Empty text values remain `""`; do not replace them with `none`.

## Adding Other Objects

Choose a type according to what the thing is operationally:

| Type | Use it for |
| --- | --- |
| `project` | Work being undertaken or maintained. |
| `powershell-operator` | A bounded PowerShell capability Ops may eventually expose safely. |
| `city-hall` | An authoritative standard, policy, registry, schema, or procedure. |
| `stock` | Known material retained because it is expected to be reused. |
| `artifact` | A durable output, package, report, image, log, or evidence record. |
| `ai-workflow` | A defined operational process in which AI participates. |

Do not classify by file extension or storage location. A reusable script can be stock; it becomes a PowerShell operator only when it represents a bounded, understood capability. A report produced by a project is an artifact, not stock, unless it is deliberately retained for reuse.

For every type, start from the default payload shown by the app. Edit values without renaming, removing, adding, or reordering its fields. Lists such as `parameters`, `hashes`, and `steps` may remain empty until you have supported facts to record.

## Relationships

Create relationships after both objects exist.

Select the source object, click **Create Link**, select the target, choose a canonical relationship type, and write a brief summary explaining why the link matters. Direction matters:

```text
WGS -- governs --> File Cabinet
File Cabinet -- produces --> Release Package
Project -- invokes --> Workspace Inventory
```

Deleting a relationship removes only that relationship record. Deleting an object removes its relationship records, but never deletes the recorded filesystem path or managed file.

## Important Pitfalls

- Choose the destination board and lane before clicking **New Object**.
- A draft is not stored until **Save**. Navigating away can abandon it.
- Type selection is required; `project` is not selected automatically.
- Changing an existing object's type immediately shows a new default payload, but nothing is committed until **Save**.
- Saving a changed type discards the old typed payload. Shared fields and relationships remain.
- Payload validation is strict about field names, order, and value types. Begin with the displayed default instead of composing a block from memory.
- **Open Path** launches the recorded location; it does not validate or import it.
- Record deletion is not filesystem deletion.
- Managed artifact intake and PowerShell execution are not implemented yet. Record those objects now, but continue using their existing specialist tools for copying and execution.

## A Sensible Starting Set

Do not begin by cataloging everything. A useful first set is:

1. Two or three current projects.
2. The City Hall authorities that actually govern them.
3. One or two operators you already use with those projects.
4. Important output artifacts that would otherwise be difficult to find again.
5. Relationships that answer a real operational question.

That is enough to establish the working rhythm without turning initial intake into a migration project of its own.
