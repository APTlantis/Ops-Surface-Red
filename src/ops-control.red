Red [
    Title: "Aptlantis Ops Control Surface - Red/View application"
    Needs: 'View
]

;-- Paths ---------------------------------------------------------------------

state-file: either exists? %data/ops-state.red [
    %data/ops-state.red
][
    %../data/ops-state.red
]

;-- State schema ---------------------------------------------------------------
;
; Each operational object is a fixed-position block. Keeping the persisted
; representation to Red scalar values and blocks makes the file transparent,
; portable, and safe to LOAD without evaluating it.
;
;  1 id          2 type       3 name       4 acronym
;  5 summary     6 board      7 lane       8 attention
;  9 path       10 tags      11 notes      12 pinned?
; 13 updated-at
;
; Relationship records are blocks of:
; [id source-id type target-id status summary required? notes]

object-id:       1
object-type:     2
object-name:     3
object-acronym:  4
object-summary:  5
object-board:    6
object-lane:     7
object-attn:     8
object-path:     9
object-tags:    10
object-notes:   11
object-pinned:  12
object-updated: 13

boards: [
    ["primary" "Operations Control" "Objects requiring current operational attention."]
    ["secondary" "Broader Work Board" "Unfinished, experimental, paused, or non-primary work."]
]

lanes: [
    ["city-hall" "primary" "City Hall Objects"]
    ["stock" "primary" "Stock / Reference"]
    ["operators" "primary" "Operators"]
    ["project-1" "primary" "Projects / Current"]
    ["project-2" "primary" "Projects / Maintain"]
    ["project-3" "primary" "Projects / Watch"]
    ["work-1" "secondary" "Active Work"]
    ["work-2" "secondary" "Planned"]
    ["work-3" "secondary" "Experimental"]
    ["work-4" "secondary" "Paused"]
    ["work-5" "secondary" "Blocked"]
    ["work-6" "secondary" "Holding"]
]

object-types: [
    "project"
    "powershell-operator"
    "city-hall"
    "stock"
    "artifact"
    "ai-workflow"
]

seed-objects: [
    ["workspace-governance-standard" "city-hall" "Workspace Governance Standard" "WGS"
        "Governs workspace structure, provenance, and operating rules."
        "primary" "city-hall" "current" "D:\.city_hall\WGS\README.md"
        "CityHall, Governance, Standard" "" true "2026-09-05"]
    ["project-proposal-standard" "city-hall" "Project Proposal Standard" "PPS"
        "Defines how project proposals become governable work."
        "primary" "city-hall" "current" "D:\.city_hall\PPS\README.md"
        "CityHall, Governance, Standard" "" false "2026-09-05"]
    ["workspace-inventory" "powershell-operator" "Workspace Inventory" ""
        "Read-only inventory of local workspace roots and manifests."
        "primary" "operators" "available" "D:\.city_hall\Operators\workspace-inventory.ps1"
        "Operator, Workspace" "Mutation: read-only" true "2026-09-05"]
    ["release-readme-stock" "stock" "Release README Stock" ""
        "Reusable release README structure for Aptlantis projects."
        "primary" "stock" "current" "D:\.city_hall\stock\Release README Stock.md"
        "Stock, Reference" "Mode: instantiate" false "2026-09-05"]
    ["file-cabinet" "project" "File Cabinet" ""
        "Personal vault and artifact manager for curated archives."
        "primary" "project-1" "next" "D:\DRS\File Cabinet"
        "Project, Workspace" "" true "2026-09-05"]
    ["structra" "project" "Structra" ""
        "Visual structured-data builder for JSON, XML, TOML, and YAML."
        "primary" "project-2" "current" "D:\DRS\Structra"
        "Project, Workspace" "" false "2026-09-05"]
    ["aegis" "project" "Aegis" ""
        "Key manager and security operations surface."
        "primary" "project-3" "watch" "D:\DRS\Aegis"
        "Project, Security" "" false "2026-09-05"]
    ["wayfinder" "project" "Wayfinder" ""
        "Workspace cleanup runner with inspect-report-fix loops."
        "secondary" "work-1" "active" "D:\DRS\Wayfinder"
        "Project, Workspace" "" true "2026-09-05"]
]

seed-relationships: [
    ["file-cabinet-governed-by-wgs" "file-cabinet" "governed_by"
        "workspace-governance-standard" "active"
        "File Cabinet is governed by WGS." true ""]
]

objects: copy []
relationships: copy []
current-board: "primary"
current-lane: "city-hall"
selected-object: none
visible-objects: copy []
status-message: "Ready"

;-- Persistence ----------------------------------------------------------------

save-state: does [
    save state-file reduce [objects relationships]
    status-message: rejoin ["Saved " length? objects " objects"]
]

load-state: does [
    either exists? state-file [
        loaded-state: attempt [load state-file]
        either all [
            block? loaded-state
            2 = length? loaded-state
            block? first loaded-state
            block? second loaded-state
        ][
            objects: first loaded-state
            relationships: second loaded-state
            status-message: rejoin ["Loaded " length? objects " objects"]
        ][
            objects: copy/deep seed-objects
            relationships: copy/deep seed-relationships
            status-message: "State invalid; loaded safe seed data"
        ]
    ][
        objects: copy/deep seed-objects
        relationships: copy/deep seed-relationships
        save-state
        status-message: "Created initial local state"
    ]
]

;-- Queries --------------------------------------------------------------------

board-definition: func [board-id [string!]][
    foreach board boards [if board-id = first board [return board]]
    first boards
]

lanes-for-board: func [board-id [string!]][
    result: copy []
    foreach lane lanes [if board-id = second lane [append/only result lane]]
    result
]

objects-for-lane: func [board-id [string!] lane-id [string!] query [string!]][
    result: copy []
    needle: lowercase copy trim query
    foreach item objects [
        if all [
            board-id = pick item object-board
            lane-id = pick item object-lane
            any [
                empty? needle
                find lowercase copy pick item object-name needle
                find lowercase copy pick item object-summary needle
                find lowercase copy pick item object-tags needle
            ]
        ][append/only result item]
    ]
    result
]

lane-by-id: func [lane-id [string!]][
    foreach lane lanes [if lane-id = first lane [return lane]]
    none
]

object-label: func [item [block!]][
    marker: either pick item object-pinned ["* "][""]
    rejoin [marker pick item object-name "  [" pick item object-type "]"]
]

make-id: func [name [string!]][
    candidate: lowercase copy trim name
    replace/all candidate " " "-"
    replace/all candidate "_" "-"
    if empty? candidate [candidate: rejoin ["object-" 1 + length? objects]]
    base: copy candidate
    suffix: 2
    while [not none? find-object candidate][
        candidate: rejoin [base "-" suffix]
        suffix: suffix + 1
    ]
    candidate
]

find-object: func [id [string!]][
    foreach item objects [if id = pick item object-id [return item]]
    none
]

today-text: does [form now/date]

;-- UI synchronization ---------------------------------------------------------

refresh-lanes: does [
    active-lanes: lanes-for-board current-board
    lane-names: copy []
    foreach lane active-lanes [append lane-names third lane]
    lane-list/data: lane-names
    selected-position: 1
    repeat index length? active-lanes [
        if current-lane = first pick active-lanes index [selected-position: index]
    ]
    lane-list/selected: selected-position
    show lane-list
]

refresh-objects: does [
    visible-objects: objects-for-lane current-board current-lane search-box/text
    labels: copy []
    foreach item visible-objects [append labels object-label item]
    object-list/data: labels
    selected-position: 0
    if selected-object [
        repeat index length? visible-objects [
            candidate: pick visible-objects index
            if (pick selected-object object-id) = (pick candidate object-id) [
                selected-position: index
            ]
        ]
    ]
    if all [zero? selected-position not empty? labels] [selected-position: 1]
    object-list/selected: either zero? selected-position [none][selected-position]
    board: board-definition current-board
    board-title/text: second board
    board-subtitle/text: third board
    lane: lane-by-id current-lane
    lane-title/text: either lane [third lane]["Lane"]
    metric-text/text: rejoin [
        length? objects " objects  |  "
        length? relationships " relationships  |  "
        length? visible-objects " visible"
    ]
    show [object-list board-title board-subtitle lane-title metric-text]
    either zero? selected-position [clear-inspector][select-visible selected-position]
]

refresh-all: does [
    refresh-lanes
    refresh-objects
    status-bar/text: status-message
    show status-bar
]

select-visible: func [position [integer!]][
    if any [position < 1 position > length? visible-objects] [exit]
    selected-object: pick visible-objects position
    inspector-type/text: uppercase copy pick selected-object object-type
    name-box/text: pick selected-object object-name
    acronym-box/text: pick selected-object object-acronym
    summary-box/text: pick selected-object object-summary
    attention-box/text: pick selected-object object-attn
    path-box/text: pick selected-object object-path
    tags-box/text: pick selected-object object-tags
    notes-box/text: pick selected-object object-notes
    pinned-box/data: pick selected-object object-pinned
    show [
        inspector-type name-box acronym-box summary-box attention-box
        path-box tags-box notes-box pinned-box
    ]
]

clear-inspector: does [
    selected-object: none
    inspector-type/text: "NO OBJECT SELECTED"
    foreach face reduce [name-box acronym-box summary-box attention-box path-box tags-box notes-box][
        face/text: ""
    ]
    pinned-box/data: false
    show [
        inspector-type name-box acronym-box summary-box attention-box
        path-box tags-box notes-box pinned-box
    ]
]

select-board: func [board-id [string!]][
    current-board: board-id
    active-lanes: lanes-for-board current-board
    current-lane: first first active-lanes
    selected-object: none
    refresh-all
]

select-lane: func [position [integer!]][
    active-lanes: lanes-for-board current-board
    if any [position < 1 position > length? active-lanes] [exit]
    current-lane: first pick active-lanes position
    refresh-objects
]

;-- Mutations ------------------------------------------------------------------

new-object: does [
    new-name: rejoin ["New " 1 + length? objects]
    item: reduce [
        make-id new-name "project" new-name "" "Describe why this object matters."
        current-board current-lane "unclassified" "" "Project" "" false today-text
    ]
    append/only objects item
    save-state
    refresh-objects
    object-list/selected: length? visible-objects
    show object-list
    select-visible length? visible-objects
    focus name-box
]

save-object: does [
    if none? selected-object [exit]
    if empty? trim copy name-box/text [
        status-message: "Name is required"
        status-bar/text: status-message
        show status-bar
        exit
    ]
    poke selected-object object-name name-box/text
    poke selected-object object-acronym acronym-box/text
    poke selected-object object-summary summary-box/text
    poke selected-object object-attn attention-box/text
    poke selected-object object-path path-box/text
    poke selected-object object-tags tags-box/text
    poke selected-object object-notes notes-box/text
    poke selected-object object-pinned to logic! pinned-box/data
    poke selected-object object-updated today-text
    save-state
    refresh-objects
]

move-selected: func [target-board [string!]][
    if none? selected-object [exit]
    target-lanes: lanes-for-board target-board
    poke selected-object object-board target-board
    poke selected-object object-lane first first target-lanes
    poke selected-object object-updated today-text
    save-state
    selected-object: none
    status-message: rejoin ["Moved object to " target-board]
    refresh-all
]

delete-selected: does [
    if none? selected-object [exit]
    doomed-id: pick selected-object object-id
    position: index? find/only objects selected-object
    remove at objects position
    kept: copy []
    foreach relation relationships [
        unless any [doomed-id = second relation doomed-id = fourth relation][
            append/only kept relation
        ]
    ]
    relationships: kept
    selected-object: none
    save-state
    status-message: rejoin ["Deleted object record: " doomed-id]
    refresh-all
]

open-selected-path: does [
    if none? selected-object [exit]
    target: trim copy pick selected-object object-path
    if empty? target [
        status-message: "No path is recorded for this object"
        status-bar/text: status-message
        show status-bar
        exit
    ]
    escaped: replace/all copy target {"} {""}
    attempt [call rejoin [{explorer.exe "} escaped {"}]]
    status-message: rejoin ["Opened: " target]
    status-bar/text: status-message
    show status-bar
]

confirm-delete: does [
    if none? selected-object [exit]
    answer: confirm rejoin [
        "Delete the record for ^"" pick selected-object object-name "^"?^/"
        "Linked relationship records will also be removed. Managed files are untouched."
    ]
    if answer [delete-selected]
]

;-- Native Red/View surface ----------------------------------------------------

load-state

main-window: layout [
    title "Aptlantis Ops"
    backdrop 20.26.40
    style section-label: text 110x24 font-color 132.150.180 font-size 9
    style action: button 108x30

    across
    text "APT" 38x38 center bold font-size 15 font-color 232.241.255 43.105.180
    space 10x0
    board-title: text "Operations Control" 420x28 bold font-size 18 font-color 232.241.255
    button "PRIMARY" 90x28 [select-board "primary"]
    button "SECONDARY" 100x28 [select-board "secondary"]
    return

    pad 52x-8
    board-subtitle: text "" 630x26 font-color 142.160.188
    return

    box 1010x1 49.61.82
    return

    across
    panel 210x650 24.31.47 [
        below
        text "WORKSPACE" 180x24 bold font-color 118.171.231
        search-box: field "" 180x30 hint "Search objects" [refresh-objects]
        text "LANES" 180x24 bold font-color 132.150.180
        lane-list: text-list 180x430 data [] [select-lane face/selected]
        action "New Object" [new-object]
        metric-text: text "" 180x52 font-color 132.150.180 wrap
    ]

    panel 380x650 27.35.52 [
        below
        lane-title: text "Lane" 350x30 bold font-size 15 font-color 232.241.255
        text "Operational objects surfaced here" 350x24 font-color 132.150.180
        object-list: text-list 350x530 data [] [select-visible face/selected]
        text "* pinned object" 350x24 font-color 132.150.180
    ]

    panel 400x650 24.31.47 [
        below
        inspector-type: text "NO OBJECT SELECTED" 370x24 bold font-color 107.190.255
        section-label "NAME"
        name-box: field "" 370x28
        section-label "ACRONYM"
        acronym-box: field "" 370x28
        section-label "SUMMARY"
        summary-box: area "" 370x72
        across
        panel 180x60 24.31.47 [
            below
            text "ATTENTION" 170x20 font-color 132.150.180 font-size 9
            attention-box: field "" 170x28
        ]
        panel 180x60 24.31.47 [
            below
            text "PINNED" 170x20 font-color 132.150.180 font-size 9
            pinned-box: check "Keep surfaced" false
        ]
        return
        section-label "PATH / TARGET"
        path-box: field "" 370x28
        section-label "TAGS"
        tags-box: field "" 370x28
        section-label "NOTES"
        notes-box: area "" 370x72
        across
        action "Save" [save-object]
        action "Open Path" [open-selected-path]
        action "Move Board" [
            move-selected either current-board = "primary" ["secondary"]["primary"]
        ]
        return
        button "Delete Record" 350x30 [confirm-delete]
    ]
    return

    status-bar: text status-message 1010x30 font-color 148.170.200
]

view/no-wait main-window
refresh-all
do-events
