[
    ["workspace-governance-standard" "city-hall" "Workspace Governance Standard" "WGS" {Governs workspace structure, provenance, and operating rules.} "primary" "city-hall" "current" "D:\.city_hall\WGS\README.md" "CityHall, Governance, Standard" "" true "2026-09-05"]
    ["project-proposal-standard" "city-hall" "Project Proposal Standard" "PPS" {Defines how project proposals become governable work.} "primary" "city-hall" "current" "D:\.city_hall\PPS\README.md" "CityHall, Governance, Standard" "" false "2026-09-05"]
    ["workspace-inventory" "powershell-operator" "Workspace Inventory" "" {Read-only inventory of local workspace roots and manifests.} "primary" "operators" "available" "D:\.city_hall\Operators\workspace-inventory.ps1" "Operator, Workspace" "Mutation: read-only" true "2026-09-05"]
    ["release-readme-stock" "stock" "Release README Stock" "" {Reusable release README structure for Aptlantis projects.} "primary" "stock" "current" "D:\.city_hall\stock\Release README Stock.md" "Stock, Reference" "Mode: instantiate" false "2026-09-05"]
    ["file-cabinet" "project" "File Cabinet" "" {Personal vault and artifact manager for curated archives.} "primary" "project-1" "next" "D:\DRS\File Cabinet" "Project, Workspace" "" true "2026-09-05"]
    ["structra" "project" "Structra" "" {Visual structured-data builder for JSON, XML, TOML, and YAML.} "primary" "project-2" "current" "D:\DRS\Structra" "Project, Workspace" "" false "2026-09-05"]
    ["aegis" "project" "Aegis" "" "Key manager and security operations surface." "primary" "project-3" "watch" "D:\DRS\Aegis" "Project, Security" "" false "2026-09-05"]
    ["wayfinder" "project" "Wayfinder" "" {Workspace cleanup runner with inspect-report-fix loops.} "secondary" "work-1" "active" "D:\DRS\Wayfinder" "Project, Workspace" "" true "2026-09-05"]
] [
    ["file-cabinet-governed-by-wgs" "file-cabinet" "governed_by" "workspace-governance-standard" "active" "File Cabinet is governed by WGS." true ""]
]