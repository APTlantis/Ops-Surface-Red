import {
  BoardId,
  BoardLane,
  AiWorkflowPayload,
  ArtifactPayload,
  CityHallPayload,
  FieldDefinition,
  ObjectBoardPlacement,
  ObjectType,
  ObjectTypeDefinition,
  OperationalObject,
  PowerShellOperatorPayload,
  ProjectPayload,
  StockPayload,
} from "./types";

export const primaryLanes: BoardLane[] = [
  { id: "city-hall", boardId: "primary", title: "City Hall Objects", tone: "violet", allowedTypes: ["city-hall"] },
  { id: "stock", boardId: "primary", title: "Stock / Reference", tone: "blue", allowedTypes: ["stock"] },
  { id: "powershell", boardId: "primary", title: "Operators", tone: "cyan", allowedTypes: ["powershell-operator", "ai-workflow"] },
  { id: "project-1", boardId: "primary", title: "Projects", tone: "amber", allowedTypes: ["project", "artifact"] },
  { id: "project-2", boardId: "primary", title: "Projects", tone: "green", allowedTypes: ["project", "artifact"] },
  { id: "project-3", boardId: "primary", title: "Projects", tone: "rose", allowedTypes: ["project", "artifact"] },
];

export const secondaryLanes: BoardLane[] = [
  { id: "work-1", boardId: "secondary", title: "Work Lane 1", tone: "violet" },
  { id: "work-2", boardId: "secondary", title: "Work Lane 2", tone: "blue" },
  { id: "work-3", boardId: "secondary", title: "Work Lane 3", tone: "cyan" },
  { id: "work-4", boardId: "secondary", title: "Work Lane 4", tone: "amber" },
  { id: "work-5", boardId: "secondary", title: "Work Lane 5", tone: "green" },
  { id: "work-6", boardId: "secondary", title: "Work Lane 6", tone: "rose" },
];

export const boardLanes = [...primaryLanes, ...secondaryLanes];

const identityFields: FieldDefinition[] = [
  { path: "identity.name", label: "Name", kind: "text", required: true },
  { path: "identity.summary", label: "Summary", kind: "textarea" },
];

const metadataFields: FieldDefinition[] = [
  { path: "metadata.tags", label: "Tags", kind: "tags" },
  { path: "metadata.notes", label: "Notes", kind: "textarea" },
];

function stamp() {
  return new Date().toISOString();
}

function baseObject<TType extends ObjectType>(type: TType, schema: string, placement: Pick<ObjectBoardPlacement, "board" | "lane">) {
  const now = stamp();
  return {
    id: "",
    objectType: type,
    schema,
    schemaVersion: "0.1",
    identity: {
      id: "",
      name: "",
      summary: "",
    },
    board: {
      board: placement.board,
      lane: placement.lane,
      pinned: false,
    },
    metadata: {
      tags: [],
      notes: "",
      createdAt: now,
      updatedAt: now,
    },
    createdAt: now,
    updatedAt: now,
    cardOrder: 0,
  };
}

const projectPayload = (): ProjectPayload => ({
  classification: {
    kind: "",
    lifecycle: "",
    attention: "",
    availability: "",
  },
  location: {
    root: "",
    repository: "",
  },
  release: {
    released: false,
    version: "",
    targetVersion: "",
  },
  operation: {
    defaultIde: "",
    defaultTerminal: "",
  },
  governance: {
    cityHallStatus: "",
  },
});

const operatorPayload = (): PowerShellOperatorPayload => ({
  source: {
    script: "",
  },
  execution: {
    scope: "",
    workingDirectory: "",
    elevation: "none",
    mutation: "read-only",
    shell: "pwsh",
  },
  parameters: {
    discovery: "powershell",
  },
  output: {
    kind: "console",
    artifactPath: "",
  },
  state: {
    enabled: true,
    lastRun: "",
    lastResult: "",
  },
});

const cityHallPayload = (): CityHallPayload => ({
  document: {
    path: "",
    version: "",
    status: "",
  },
  governance: {
    domain: "",
    maturity: "",
    adoption: "",
    standardized: false,
  },
  operation: {
    attention: "",
  },
});

const stockPayload = (): StockPayload => ({
  classification: {
    kind: "",
    attention: "",
  },
  source: {
    path: "",
    format: "",
  },
  usage: {
    mode: "",
    currentRevision: "",
    enabled: true,
  },
});

const artifactPayload = (): ArtifactPayload => ({
  classification: {
    kind: "",
  },
  source: {
    path: "",
    format: "",
    capturedAt: "",
  },
  context: {
    version: "",
    batch: "",
    context: "",
  },
  integrity: {
    sizeBytes: 0,
    hash: "",
    hashAlgorithm: "",
  },
  state: {
    current: true,
  },
});

const aiWorkflowPayload = (): AiWorkflowPayload => ({
  workflow: {
    purpose: "",
    promptPath: "",
    inputSchema: "",
    outputKind: "",
  },
  execution: {
    provider: "",
    model: "",
    requiresModel: true,
  },
  state: {
    enabled: true,
    lastRun: "",
    lastResult: "",
  },
});

export const objectRegistry: Record<ObjectType, ObjectTypeDefinition> = {
  project: {
    type: "project",
    schema: "aptlantis.project",
    schemaVersion: "0.1",
    label: "Project",
    shortLabel: "Project",
    accent: "cyan",
    defaultLane: "project-1",
    inspectorTabs: [
      { id: "overview", label: "Overview", capability: "inspect", groupTitles: ["Identity / Summary", "Lifecycle / Attention"] },
      { id: "location", label: "Location", capability: "open-project", groupTitles: ["Root / Repository"] },
      { id: "release", label: "Release", capability: "release", groupTitles: ["Release / Version", "Governance State"] },
      { id: "artifacts", label: "Artifacts", capability: "import-artifacts" },
      { id: "placement", label: "Placement", capability: "place" },
      { id: "metadata", label: "Metadata", capability: "tag", groupTitles: ["Metadata"] },
    ],
    creationGroups: [
      { title: "Identity / Summary", fields: identityFields },
      {
        title: "Lifecycle / Attention",
        fields: [
          { path: "payload.classification.kind", label: "Kind", kind: "text" },
          { path: "payload.classification.lifecycle", label: "Lifecycle", kind: "text" },
          { path: "payload.classification.attention", label: "Attention", kind: "text" },
          { path: "payload.classification.availability", label: "Availability", kind: "text" },
        ],
      },
      {
        title: "Location",
        fields: [
          { path: "payload.location.root", label: "Root Path", kind: "text" },
          { path: "payload.location.repository", label: "Repository", kind: "text" },
        ],
      },
      {
        title: "Release / Governance",
        fields: [
          { path: "payload.release.released", label: "Released", kind: "checkbox" },
          { path: "payload.release.version", label: "Version", kind: "text" },
          { path: "payload.release.targetVersion", label: "Target Version", kind: "text" },
          { path: "payload.governance.cityHallStatus", label: "City Hall Status", kind: "text" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    inspectorGroups: [
      { title: "Identity / Summary", fields: identityFields },
      {
        title: "Lifecycle / Attention",
        fields: [
          { path: "payload.classification.kind", label: "Kind", kind: "text" },
          { path: "payload.classification.lifecycle", label: "Lifecycle", kind: "text" },
          { path: "payload.classification.attention", label: "Attention", kind: "text" },
          { path: "payload.classification.availability", label: "Availability", kind: "text" },
        ],
      },
      {
        title: "Root / Repository",
        fields: [
          { path: "payload.location.root", label: "Root Path", kind: "text" },
          { path: "payload.location.repository", label: "Repository", kind: "text" },
        ],
      },
      {
        title: "Release / Version",
        fields: [
          { path: "payload.release.released", label: "Released", kind: "checkbox" },
          { path: "payload.release.version", label: "Version", kind: "text" },
          { path: "payload.release.targetVersion", label: "Target Version", kind: "text" },
        ],
      },
      { title: "Governance State", fields: [{ path: "payload.governance.cityHallStatus", label: "City Hall Status", kind: "text" }] },
      { title: "Metadata", fields: metadataFields },
    ],
    createEmpty: (placement) => ({ ...baseObject("project", "aptlantis.project", placement), payload: projectPayload() }),
  },
  "powershell-operator": {
    type: "powershell-operator",
    schema: "aptlantis.powershell-operator",
    schemaVersion: "0.1",
    label: "PowerShell Operator",
    shortLabel: "Operator",
    accent: "blue",
    defaultLane: "powershell",
    inspectorTabs: [
      { id: "overview", label: "Overview", capability: "inspect", groupTitles: ["Identity / Summary"] },
      { id: "source", label: "Source", capability: "open-script", groupTitles: ["Script Path"] },
      { id: "execution", label: "Execution", capability: "run", groupTitles: ["Execution Contract", "Output / Enabled State"] },
      { id: "placement", label: "Placement", capability: "place" },
      { id: "metadata", label: "Metadata", capability: "tag", groupTitles: ["Metadata"] },
    ],
    creationGroups: [
      { title: "Identity / Summary", fields: identityFields },
      { title: "Source", fields: [{ path: "payload.source.script", label: "Script Path", kind: "text" }] },
      {
        title: "Execution",
        fields: [
          { path: "payload.execution.scope", label: "Scope", kind: "text" },
          { path: "payload.execution.workingDirectory", label: "Working Directory", kind: "text" },
          { path: "payload.execution.elevation", label: "Elevation", kind: "text" },
          { path: "payload.execution.mutation", label: "Mutation Level", kind: "text" },
          { path: "payload.execution.shell", label: "Shell", kind: "text" },
        ],
      },
      {
        title: "Output / State",
        fields: [
          { path: "payload.output.kind", label: "Output Type", kind: "text" },
          { path: "payload.output.artifactPath", label: "Artifact Path", kind: "text" },
          { path: "payload.state.enabled", label: "Enabled", kind: "checkbox" },
          { path: "payload.state.lastRun", label: "Last Run", kind: "text" },
          { path: "payload.state.lastResult", label: "Last Result", kind: "text" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    inspectorGroups: [
      { title: "Identity / Summary", fields: identityFields },
      { title: "Script Path", fields: [{ path: "payload.source.script", label: "Script Path", kind: "text" }] },
      {
        title: "Execution Contract",
        fields: [
          { path: "payload.execution.scope", label: "Scope", kind: "text" },
          { path: "payload.execution.workingDirectory", label: "Working Directory", kind: "text" },
          { path: "payload.execution.elevation", label: "Elevation", kind: "text" },
          { path: "payload.execution.mutation", label: "Mutation Level", kind: "text" },
          { path: "payload.execution.shell", label: "Shell", kind: "text" },
        ],
      },
      {
        title: "Output / Enabled State",
        fields: [
          { path: "payload.output.kind", label: "Output Type", kind: "text" },
          { path: "payload.output.artifactPath", label: "Artifact Path", kind: "text" },
          { path: "payload.state.enabled", label: "Enabled", kind: "checkbox" },
          { path: "payload.state.lastRun", label: "Last Run", kind: "text" },
          { path: "payload.state.lastResult", label: "Last Result", kind: "text" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    createEmpty: (placement) => ({ ...baseObject("powershell-operator", "aptlantis.powershell-operator", placement), payload: operatorPayload() }),
  },
  "city-hall": {
    type: "city-hall",
    schema: "aptlantis.city-hall",
    schemaVersion: "0.1",
    label: "City Hall Object",
    shortLabel: "City Hall",
    accent: "violet",
    defaultLane: "city-hall",
    inspectorTabs: [
      { id: "overview", label: "Overview", capability: "inspect", groupTitles: ["Identity / Acronym / Summary"] },
      { id: "document", label: "Document", capability: "open-document", groupTitles: ["Document Version / Status"] },
      { id: "governance", label: "Governance", capability: "govern", groupTitles: ["Governance State"] },
      { id: "placement", label: "Placement", capability: "place" },
      { id: "metadata", label: "Metadata", capability: "tag", groupTitles: ["Metadata"] },
    ],
    creationGroups: [
      {
        title: "Identity / Acronym / Summary",
        fields: [
          { path: "identity.name", label: "Name", kind: "text", required: true },
          { path: "identity.acronym", label: "Acronym", kind: "text" },
          { path: "identity.summary", label: "Summary", kind: "textarea" },
        ],
      },
      {
        title: "Document",
        fields: [
          { path: "payload.document.path", label: "Document Path", kind: "text" },
          { path: "payload.document.version", label: "Document Version", kind: "text" },
          { path: "payload.document.status", label: "Document Status", kind: "text" },
        ],
      },
      {
        title: "Governance",
        fields: [
          { path: "payload.governance.domain", label: "Governance Domain", kind: "text" },
          { path: "payload.governance.maturity", label: "Maturity", kind: "text" },
          { path: "payload.governance.adoption", label: "Adoption", kind: "text" },
          { path: "payload.governance.standardized", label: "Standardized", kind: "checkbox" },
          { path: "payload.operation.attention", label: "Attention", kind: "text" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    inspectorGroups: [
      {
        title: "Identity / Acronym / Summary",
        fields: [
          { path: "identity.name", label: "Name", kind: "text", required: true },
          { path: "identity.acronym", label: "Acronym", kind: "text" },
          { path: "identity.summary", label: "Summary", kind: "textarea" },
        ],
      },
      {
        title: "Document Version / Status",
        fields: [
          { path: "payload.document.path", label: "Document Path", kind: "text" },
          { path: "payload.document.version", label: "Document Version", kind: "text" },
          { path: "payload.document.status", label: "Document Status", kind: "text" },
        ],
      },
      {
        title: "Governance State",
        fields: [
          { path: "payload.governance.domain", label: "Governance Domain", kind: "text" },
          { path: "payload.governance.maturity", label: "Maturity", kind: "text" },
          { path: "payload.governance.adoption", label: "Adoption", kind: "text" },
          { path: "payload.governance.standardized", label: "Standardized", kind: "checkbox" },
          { path: "payload.operation.attention", label: "Attention", kind: "text" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    createEmpty: (placement) => ({ ...baseObject("city-hall", "aptlantis.city-hall", placement), payload: cityHallPayload() }),
  },
  stock: {
    type: "stock",
    schema: "aptlantis.stock",
    schemaVersion: "0.1",
    label: "Stock / Reference Object",
    shortLabel: "Stock",
    accent: "amber",
    defaultLane: "stock",
    inspectorTabs: [
      { id: "overview", label: "Overview", capability: "inspect", groupTitles: ["Identity / Summary", "Classification / Attention"] },
      { id: "source", label: "Source", capability: "open-source", groupTitles: ["Source Material"] },
      { id: "usage", label: "Usage", capability: "instantiate", groupTitles: ["Usage Contract"] },
      { id: "placement", label: "Placement", capability: "place" },
      { id: "metadata", label: "Metadata", capability: "tag", groupTitles: ["Metadata"] },
    ],
    creationGroups: [
      { title: "Identity / Summary", fields: identityFields },
      {
        title: "Classification / Attention",
        fields: [
          { path: "payload.classification.kind", label: "Kind", kind: "text" },
          { path: "payload.classification.attention", label: "Attention", kind: "text" },
        ],
      },
      {
        title: "Source Material",
        fields: [
          { path: "payload.source.path", label: "Source Path", kind: "text" },
          { path: "payload.source.format", label: "Format", kind: "text" },
        ],
      },
      {
        title: "Usage Contract",
        fields: [
          { path: "payload.usage.mode", label: "Mode", kind: "text" },
          { path: "payload.usage.currentRevision", label: "Current Revision", kind: "text" },
          { path: "payload.usage.enabled", label: "Enabled", kind: "checkbox" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    inspectorGroups: [
      { title: "Identity / Summary", fields: identityFields },
      {
        title: "Classification / Attention",
        fields: [
          { path: "payload.classification.kind", label: "Kind", kind: "text" },
          { path: "payload.classification.attention", label: "Attention", kind: "text" },
        ],
      },
      {
        title: "Source Material",
        fields: [
          { path: "payload.source.path", label: "Source Path", kind: "text" },
          { path: "payload.source.format", label: "Format", kind: "text" },
        ],
      },
      {
        title: "Usage Contract",
        fields: [
          { path: "payload.usage.mode", label: "Mode", kind: "text" },
          { path: "payload.usage.currentRevision", label: "Current Revision", kind: "text" },
          { path: "payload.usage.enabled", label: "Enabled", kind: "checkbox" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    createEmpty: (placement) => ({ ...baseObject("stock", "aptlantis.stock", placement), payload: stockPayload() }),
  },
  artifact: {
    type: "artifact",
    schema: "aptlantis.artifact",
    schemaVersion: "0.1",
    label: "Artifact",
    shortLabel: "Artifact",
    accent: "rose",
    defaultLane: "project-1",
    inspectorTabs: [
      { id: "overview", label: "Overview", capability: "inspect", groupTitles: ["Identity / Summary", "Classification"] },
      { id: "source", label: "Source", capability: "preview", groupTitles: ["Source / Capture"] },
      { id: "context", label: "Context", capability: "context", groupTitles: ["Artifact Context"] },
      { id: "integrity", label: "Integrity", capability: "verify", groupTitles: ["Integrity / State"] },
      { id: "placement", label: "Placement", capability: "place" },
      { id: "metadata", label: "Metadata", capability: "tag", groupTitles: ["Metadata"] },
    ],
    creationGroups: [
      { title: "Identity / Summary", fields: identityFields },
      { title: "Classification", fields: [{ path: "payload.classification.kind", label: "Kind", kind: "text" }] },
      {
        title: "Source / Capture",
        fields: [
          { path: "payload.source.path", label: "Path", kind: "text" },
          { path: "payload.source.format", label: "Format", kind: "text" },
          { path: "payload.source.capturedAt", label: "Captured At", kind: "text" },
        ],
      },
      {
        title: "Artifact Context",
        fields: [
          { path: "payload.context.version", label: "Version", kind: "text" },
          { path: "payload.context.batch", label: "Batch", kind: "text" },
          { path: "payload.context.context", label: "Context", kind: "textarea" },
        ],
      },
      {
        title: "Integrity / State",
        fields: [
          { path: "payload.integrity.sizeBytes", label: "Size Bytes", kind: "number" },
          { path: "payload.integrity.hash", label: "Hash", kind: "text" },
          { path: "payload.integrity.hashAlgorithm", label: "Hash Algorithm", kind: "text" },
          { path: "payload.state.current", label: "Current", kind: "checkbox" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    inspectorGroups: [
      { title: "Identity / Summary", fields: identityFields },
      { title: "Classification", fields: [{ path: "payload.classification.kind", label: "Kind", kind: "text" }] },
      {
        title: "Source / Capture",
        fields: [
          { path: "payload.source.path", label: "Path", kind: "text" },
          { path: "payload.source.format", label: "Format", kind: "text" },
          { path: "payload.source.capturedAt", label: "Captured At", kind: "text" },
        ],
      },
      {
        title: "Artifact Context",
        fields: [
          { path: "payload.context.version", label: "Version", kind: "text" },
          { path: "payload.context.batch", label: "Batch", kind: "text" },
          { path: "payload.context.context", label: "Context", kind: "textarea" },
        ],
      },
      {
        title: "Integrity / State",
        fields: [
          { path: "payload.integrity.sizeBytes", label: "Size Bytes", kind: "number" },
          { path: "payload.integrity.hash", label: "Hash", kind: "text" },
          { path: "payload.integrity.hashAlgorithm", label: "Hash Algorithm", kind: "text" },
          { path: "payload.state.current", label: "Current", kind: "checkbox" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    createEmpty: (placement) => ({ ...baseObject("artifact", "aptlantis.artifact", placement), payload: artifactPayload() }),
  },
  "ai-workflow": {
    type: "ai-workflow",
    schema: "aptlantis.ai-workflow",
    schemaVersion: "0.1",
    label: "AI Workflow",
    shortLabel: "AI Workflow",
    accent: "green",
    defaultLane: "powershell",
    inspectorTabs: [
      { id: "overview", label: "Overview", capability: "inspect", groupTitles: ["Identity / Summary", "Workflow Contract"] },
      { id: "prompt", label: "Prompt", capability: "edit-prompt", groupTitles: ["Prompt / Output"] },
      { id: "execution", label: "Execution", capability: "run-workflow", groupTitles: ["Execution Backend", "Enabled State"] },
      { id: "placement", label: "Placement", capability: "place" },
      { id: "metadata", label: "Metadata", capability: "tag", groupTitles: ["Metadata"] },
    ],
    creationGroups: [
      { title: "Identity / Summary", fields: identityFields },
      {
        title: "Workflow Contract",
        fields: [
          { path: "payload.workflow.purpose", label: "Purpose", kind: "textarea" },
          { path: "payload.workflow.inputSchema", label: "Input Schema", kind: "text" },
        ],
      },
      {
        title: "Prompt / Output",
        fields: [
          { path: "payload.workflow.promptPath", label: "Prompt Path", kind: "text" },
          { path: "payload.workflow.outputKind", label: "Output Kind", kind: "text" },
        ],
      },
      {
        title: "Execution Backend",
        fields: [
          { path: "payload.execution.provider", label: "Provider", kind: "text" },
          { path: "payload.execution.model", label: "Model", kind: "text" },
          { path: "payload.execution.requiresModel", label: "Requires Model", kind: "checkbox" },
        ],
      },
      {
        title: "Enabled State",
        fields: [
          { path: "payload.state.enabled", label: "Enabled", kind: "checkbox" },
          { path: "payload.state.lastRun", label: "Last Run", kind: "text" },
          { path: "payload.state.lastResult", label: "Last Result", kind: "text" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    inspectorGroups: [
      { title: "Identity / Summary", fields: identityFields },
      {
        title: "Workflow Contract",
        fields: [
          { path: "payload.workflow.purpose", label: "Purpose", kind: "textarea" },
          { path: "payload.workflow.inputSchema", label: "Input Schema", kind: "text" },
        ],
      },
      {
        title: "Prompt / Output",
        fields: [
          { path: "payload.workflow.promptPath", label: "Prompt Path", kind: "text" },
          { path: "payload.workflow.outputKind", label: "Output Kind", kind: "text" },
        ],
      },
      {
        title: "Execution Backend",
        fields: [
          { path: "payload.execution.provider", label: "Provider", kind: "text" },
          { path: "payload.execution.model", label: "Model", kind: "text" },
          { path: "payload.execution.requiresModel", label: "Requires Model", kind: "checkbox" },
        ],
      },
      {
        title: "Enabled State",
        fields: [
          { path: "payload.state.enabled", label: "Enabled", kind: "checkbox" },
          { path: "payload.state.lastRun", label: "Last Run", kind: "text" },
          { path: "payload.state.lastResult", label: "Last Result", kind: "text" },
        ],
      },
      { title: "Metadata", fields: metadataFields },
    ],
    createEmpty: (placement) => ({ ...baseObject("ai-workflow", "aptlantis.ai-workflow", placement), payload: aiWorkflowPayload() }),
  },
};

export const objectTypes = Object.values(objectRegistry);

export function lanesForBoard(boardId: BoardId) {
  return boardLanes.filter((lane) => lane.boardId === boardId);
}

export function defaultLaneForType(objectType: ObjectType, boardId: BoardId) {
  const registryLane = objectRegistry[objectType].defaultLane;
  if (boardId === "primary") return registryLane;
  return "work-1";
}

export function laneAcceptsObject(lane: BoardLane, objectType: ObjectType) {
  return !lane.allowedTypes || lane.allowedTypes.includes(objectType);
}

export function getPathValue(source: OperationalObject, path: string): unknown {
  return path.split(".").reduce<unknown>((value, key) => {
    if (value && typeof value === "object" && key in value) {
      return (value as Record<string, unknown>)[key];
    }
    return undefined;
  }, source);
}

export function setPathValue<T extends OperationalObject>(source: T, path: string, value: unknown): T {
  const clone = structuredClone(source);
  const parts = path.split(".");
  let cursor: Record<string, unknown> = clone as unknown as Record<string, unknown>;
  for (const part of parts.slice(0, -1)) {
    cursor = cursor[part] as Record<string, unknown>;
  }
  cursor[parts[parts.length - 1]] = value;
  return clone;
}

export function normalizeDraftForSave(draft: OperationalObject): OperationalObject {
  const next = structuredClone(draft);
  next.identity.name = next.identity.name.trim();
  next.identity.summary = next.identity.summary.trim();
  if (next.identity.acronym !== undefined) next.identity.acronym = next.identity.acronym.trim();
  next.identity.id = next.identity.id.trim() || slugify(next.identity.name);
  next.metadata.tags = next.metadata.tags.map((tag) => tag.trim()).filter(Boolean);
  next.metadata.notes = next.metadata.notes.trim();
  return next;
}

export function slugify(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}
