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
; 13 updated-at 14 payload
;
; The payload slot is a type-specific property block. It is deliberately kept
; as data, not code, so operators can inspect and recover state directly.
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
object-payload: 14

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

relationship-types: [
    "governs"
    "implements"
    "contains"
    "depends-on"
    "produces"
    "produced-by"
    "consumes"
    "used-by"
    "operates-on"
    "executed-by"
    "invokes"
    "part-of"
    "references"
    "supersedes"
    "derived-from"
    "validates"
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
selected-relationship: none
visible-relationships: copy []
relationship-targets: copy []
draft-new?: false
proposed-object-type: none
status-message: "Ready"

;-- Persistence ----------------------------------------------------------------

default-payload: func [type-name [string!] /local template][
    template: switch/default type-name [
        "project" [
            [
                version "" completion "" phase "" next-action "" blocker ""
                manifest "" repository ""
            ]
        ]
        "powershell-operator" [
            [
                script "" entry-point "" working-directory ""
                privilege "user" mutation "read" preview-supported true
                confirmation-required false timeout-seconds 300 parameters []
            ]
        ]
        "city-hall" [
            [
                authority-class "standard" version "" scope ""
                canonical-source "" compliance-target "" evidence []
            ]
        ]
        "stock" [
            [
                stock-class "reference" format "" source "" version ""
                provenance "" verified false intended-use ""
            ]
        ]
        "artifact" [
            [
                artifact-class "report" format "" version "" produced-at ""
                size-bytes 0 canonical false published false verified false hashes []
            ]
        ]
        "ai-workflow" [
            [
                trigger "manual" autonomy "assisted" write-scope "bounded"
                approval-required false stop-condition "" steps []
            ]
        ]
    ][
        []
    ]
    copy/deep template
]

normalize-object: func [item [block!] /local payload][
    either object-payload > length? item [
        append/only item default-payload pick item object-type
    ][
        payload: pick item object-payload
        unless block? payload [
            poke item object-payload default-payload pick item object-type
        ]
    ]
    item
]

normalize-state: does [
    foreach item objects [normalize-object item]
]

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
            normalize-state
            status-message: rejoin ["Loaded " length? objects " objects"]
        ][
            objects: copy/deep seed-objects
            relationships: copy/deep seed-relationships
            normalize-state
            status-message: "State invalid; loaded safe seed data"
        ]
    ][
        objects: copy/deep seed-objects
        relationships: copy/deep seed-relationships
        normalize-state
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

index-of-object-type: func [type-name [string!] /local index][
    index: 1
    foreach candidate object-types [
        if type-name = candidate [return index]
        index: index + 1
    ]
    none
]

selected-object-type: func [/local selected][
    selected: type-list/selected
    either all [integer? selected selected >= 1 selected <= length? object-types][
        pick object-types selected
    ][
        none
    ]
]

type-context: func [type-name [string!]][
    switch type-name [
        "project" ["Work being undertaken. Track phase, next action, blocker, manifest, and repository without turning Ops into project management."]
        "powershell-operator" ["Bounded executable capability. Record script, working directory, mutation, preview, confirmation, and timeout posture."]
        "city-hall" ["Governing authority. Emphasize class, scope, canonical source, compliance target, and evidence."]
        "stock" ["Reusable known material retained for future use. Distinguish it from produced artifacts."]
        "artifact" ["Durable output or evidence. Deleting this record never deletes the referenced or managed file."]
        "ai-workflow" ["Defined AI-assisted operational process. Record trigger, autonomy, write scope, approvals, stop condition, and steps."]
        default ["Common operational record. Add meaning only where the operator can support it."]
    ]
]

payload-heading: func [type-name [string!]][
    switch/default type-name [
        "project" ["PROJECT PAYLOAD"]
        "powershell-operator" ["OPERATOR PAYLOAD"]
        "city-hall" ["CITY HALL PAYLOAD"]
        "stock" ["STOCK PAYLOAD"]
        "artifact" ["ARTIFACT PAYLOAD"]
        "ai-workflow" ["AI WORKFLOW PAYLOAD"]
    ]["TYPE PAYLOAD"]
]

payload-help: func [type-name [string!]][
    switch/default type-name [
        "project" ["version, completion, phase, next-action, blocker, manifest, repository"]
        "powershell-operator" ["script, entry-point, working-directory, privilege, mutation, preview, confirmation, timeout"]
        "city-hall" ["authority-class, version, scope, canonical-source, compliance-target, evidence"]
        "stock" ["stock-class, format, source, version, provenance, verified, intended-use"]
        "artifact" ["artifact-class, format, version, produced-at, size-bytes, canonical, published, verified, hashes"]
        "ai-workflow" ["trigger, autonomy, write-scope, approval-required, stop-condition, steps"]
    ]["Type-specific Red property block"]
]

show-payload-for-type: func [type-name [string! none!] payload [block! none!]][
    inspector-type/text: either type-name [uppercase copy type-name]["NO TYPE SELECTED"]
    inspector-context/text: either type-name [
        type-context type-name
    ][
        "Choose a type before saving this object."
    ]
    payload-title/text: either type-name [payload-heading type-name]["TYPE PAYLOAD"]
    payload-help-text/text: either type-name [
        payload-help type-name
    ][
        "Select a type to load its default payload."
    ]
    payload-box/text: either type-name [
        mold either payload [payload][default-payload type-name]
    ][
        ""
    ]
    show [inspector-type inspector-context payload-title payload-help-text payload-box]
]

change-inspector-type: func [position [integer! none!] /local next-type][
    if none? position [
        proposed-object-type: none
        show-payload-for-type none none
        exit
    ]
    next-type: selected-object-type
    if next-type = proposed-object-type [exit]
    proposed-object-type: next-type
    show-payload-for-type next-type none
]

relationships-for-object: func [item [block!] /local result item-id][
    result: copy []
    item-id: pick item object-id
    foreach relation relationships [
        if any [item-id = second relation item-id = fourth relation] [
            append/only result relation
        ]
    ]
    result
]

relationship-label: func [relation [block!] /local source target][
    source: find-object second relation
    target: find-object fourth relation
    rejoin [
        either source [pick source object-name][second relation]
        "  -- " third relation " -->  "
        either target [pick target object-name][fourth relation]
    ]
]

new-relationship-id: func [/local candidate next-number][
    next-number: 1 + length? relationships
    candidate: rejoin ["relationship-" next-number]
    while [not none? find-relation candidate] [
        next-number: next-number + 1
        candidate: rejoin ["relationship-" next-number]
    ]
    candidate
]

find-relation: func [id [string!]][
    foreach relation relationships [if id = first relation [return relation]]
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
        length? visible-objects " objects in lane"
    ]
    show [object-list board-title board-subtitle lane-title metric-text]
    either zero? selected-position [clear-inspector][select-visible selected-position]
]

refresh-relationships: does [
    visible-relationships: either selected-object [relationships-for-object selected-object][copy []]
    labels: copy []
    foreach relation visible-relationships [append labels relationship-label relation]
    relationship-list/data: labels
    relationship-list/selected: none
    selected-relationship: none
    relationship-details/text: either empty? labels [
        "No relationship records link to this object yet."
    ][
        "Select a relationship to inspect it, or create a new link."
    ]
    show [relationship-list relationship-details]
]

refresh-all: does [
    refresh-lanes
    refresh-objects
    status-bar/text: status-message
    show status-bar
]

select-visible: func [position [integer!]][
    if any [position < 1 position > length? visible-objects] [exit]
    draft-new?: false
    selected-object: pick visible-objects position
    proposed-object-type: pick selected-object object-type
    type-list/selected: index-of-object-type pick selected-object object-type
    name-box/text: pick selected-object object-name
    acronym-box/text: pick selected-object object-acronym
    summary-box/text: pick selected-object object-summary
    attention-box/text: pick selected-object object-attn
    path-box/text: pick selected-object object-path
    tags-box/text: pick selected-object object-tags
    notes-box/text: pick selected-object object-notes
    show-payload-for-type pick selected-object object-type pick selected-object object-payload
    pinned-box/data: pick selected-object object-pinned
    show [
        type-list name-box acronym-box summary-box attention-box path-box tags-box notes-box pinned-box
    ]
    refresh-relationships
]

clear-inspector: does [
    selected-object: none
    draft-new?: false
    proposed-object-type: none
    type-list/selected: none
    inspector-type/text: "NO OBJECT SELECTED"
    inspector-context/text: "Select an object to see the operating context for its type."
    foreach face reduce [name-box acronym-box summary-box attention-box path-box tags-box notes-box][
        face/text: ""
    ]
    payload-title/text: "TYPE PAYLOAD"
    payload-help-text/text: "Select an object to edit its type-specific data."
    payload-box/text: ""
    pinned-box/data: false
    refresh-relationships
    show [
        type-list inspector-type inspector-context name-box acronym-box summary-box attention-box
        path-box tags-box notes-box payload-title payload-help-text payload-box pinned-box
    ]
]

select-relationship: func [position [integer!]][
    if any [position < 1 position > length? visible-relationships] [exit]
    selected-relationship: pick visible-relationships position
    relationship-details/text: rejoin [
        "Status: " fifth selected-relationship "^/"
        "Summary: " sixth selected-relationship "^/"
        "Required: " either seventh selected-relationship ["yes"]["no"]
    ]
    show relationship-details
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
    clear-inspector
    draft-new?: true
    new-name: rejoin ["New " 1 + length? objects]
    object-list/selected: none
    name-box/text: new-name
    summary-box/text: "Describe why this object matters."
    attention-box/text: "unclassified"
    inspector-type/text: "NEW OBJECT"
    inspector-context/text: "Choose a type, fill the shared fields, then save to create the record."
    payload-help-text/text: "No object is created until Save."
    status-message: "Draft object ready; choose a type before saving"
    status-bar/text: status-message
    show [
        object-list name-box summary-box attention-box inspector-type inspector-context
        payload-help-text status-bar
    ]
    focus name-box
]

save-object: does [
    if all [none? selected-object not draft-new?] [exit]
    if empty? trim copy name-box/text [
        status-message: "Name is required"
        status-bar/text: status-message
        show status-bar
        exit
    ]
    next-type: selected-object-type
    if none? next-type [
        status-message: "Select an object type before saving"
        status-bar/text: status-message
        show status-bar
        exit
    ]
    existing-type: either selected-object [pick selected-object object-type][none]
    payload-to-save: none
    either all [selected-object next-type <> existing-type][
        payload-to-save: default-payload next-type
    ][
        parsed-payload: attempt [load payload-box/text]
        unless block? parsed-payload [
            status-message: "Typed payload must be a Red block, for example: [phase {Hardening}]"
            status-bar/text: status-message
            show status-bar
            exit
        ]
        payload-to-save: parsed-payload
    ]
    if draft-new? [
        selected-object: reduce [
            make-id name-box/text next-type name-box/text acronym-box/text summary-box/text
            current-board current-lane attention-box/text path-box/text tags-box/text
            notes-box/text to logic! pinned-box/data today-text
        ]
        append/only selected-object payload-to-save
        append/only objects selected-object
        draft-new?: false
    ]
    poke selected-object object-type next-type
    poke selected-object object-name name-box/text
    poke selected-object object-acronym acronym-box/text
    poke selected-object object-summary summary-box/text
    poke selected-object object-attn attention-box/text
    poke selected-object object-path path-box/text
    poke selected-object object-tags tags-box/text
    poke selected-object object-notes notes-box/text
    poke selected-object object-pinned to logic! pinned-box/data
    poke selected-object object-updated today-text
    poke selected-object object-payload payload-to-save
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

create-relationship: does [
    if none? selected-object [exit]
    relationship-targets: copy []
    target-labels: copy []
    selected-id: pick selected-object object-id
    foreach item objects [
        if selected-id <> pick item object-id [
            append/only relationship-targets item
            append target-labels object-label item
        ]
    ]
    if empty? target-labels [
        alert "Create another object before creating a relationship."
        exit
    ]
    relation-window: layout [
        title "Create relationship"
        backdrop 24.31.47
        below
        text "TARGET OBJECT" 360x22 bold font-color 132.150.180
        relation-target-list: text-list 360x112 data target-labels
        text "RELATIONSHIP TYPE" 360x22 bold font-color 132.150.180
        relation-type-list: text-list 170x150 data relationship-types
        relation-type-box: field "references" 180x28
        text "Select a canonical type or edit the field." 360x22 font-color 132.150.180
        text "OPERATOR SUMMARY" 360x22 bold font-color 132.150.180
        relation-summary-box: area "Describe why this link matters." 360x68
        across
        button "Create Link" 170x30 [
            if relation-type-list/selected [
                relation-type-box/text: pick relationship-types relation-type-list/selected
            ]
            if none? relation-target-list/selected [
                alert "Select a target object."
                exit
            ]
            if empty? trim copy relation-type-box/text [
                alert "A relationship type is required."
                exit
            ]
            target: pick relationship-targets relation-target-list/selected
            append/only relationships reduce [
                new-relationship-id
                pick selected-object object-id
                trim copy relation-type-box/text
                pick target object-id
                "active"
                trim copy relation-summary-box/text
                false
                ""
            ]
            save-state
            status-message: "Created relationship record"
            unview
            refresh-objects
        ]
        button "Cancel" 170x30 [unview]
    ]
    view/flags relation-window 'modal
]

delete-selected-relationship: does [
    relation-to-delete: selected-relationship
    if all [none? relation-to-delete 1 = length? visible-relationships] [
        relation-to-delete: first visible-relationships
    ]
    if none? relation-to-delete [
        status-message: "Select a relationship first (or open an object with exactly one linked relationship)"
        status-bar/text: status-message
        show status-bar
        exit
    ]
    position: index? find/only relationships relation-to-delete
    if none? position [
        status-message: "Relationship record was not found; no change was made"
        status-bar/text: status-message
        show status-bar
        exit
    ]
    remove at relationships position
    selected-relationship: none
    save-state
    status-message: "Deleted relationship record; connected objects and paths are untouched"
    refresh-objects
]

;-- Native Red/View surface ----------------------------------------------------

load-state

main-window: layout [
    title "Aptlantis Ops"
    on-close [quit]
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
    panel 210x875 24.31.47 [
        below
        text "WORKSPACE" 180x24 bold font-color 118.171.231
        search-box: field "" 180x30 hint "Search objects" [refresh-objects]
        text "LANES" 180x24 bold font-color 132.150.180
        lane-list: text-list 180x655 data [] [select-lane face/selected]
        action "New Object" [new-object]
        metric-text: text "" 180x52 font-color 132.150.180 wrap
    ]

    panel 380x875 27.35.52 [
        below
        lane-title: text "Lane" 350x30 bold font-size 15 font-color 232.241.255
        text "Operational objects surfaced here" 350x24 font-color 132.150.180
        object-list: text-list 350x755 data [] [select-visible face/selected]
        text "* pinned object" 350x24 font-color 132.150.180
    ]

    panel 400x875 24.31.47 [
        below
        inspector-type: text "NO OBJECT SELECTED" 370x24 bold font-color 107.190.255
        inspector-context: text "Select an object to see the operating context for its type." 370x38 wrap font-color 132.150.180
        section-label "LINKED RELATIONSHIPS"
        relationship-list: text-list 370x44 data [] [select-relationship face/selected]
        relationship-details: text "" 370x30 wrap font-color 132.150.180
        across
        button "Create Link" 180x30 [create-relationship]
        button "Delete Link" 180x30 [delete-selected-relationship]
        return
        section-label "TYPE"
        type-list: text-list 370x72 data object-types [change-inspector-type face/selected]
        section-label "NAME"
        name-box: field "" 370x28
        section-label "ACRONYM"
        acronym-box: field "" 370x28
        section-label "SUMMARY"
        summary-box: area "" 370x54
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
        payload-title: text "TYPE PAYLOAD" 370x20 bold font-color 132.150.180 font-size 9
        payload-help-text: text "" 370x30 wrap font-color 132.150.180
        payload-box: area "" 370x78
        section-label "NOTES"
        notes-box: area "" 370x40
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
