import { invoke } from "@tauri-apps/api/core";
import { open as openDialog } from "@tauri-apps/plugin-dialog";
import { mockBoardData } from "./mockData";
import { objectRegistry, slugify } from "./objectRegistry";
import {
  BoardData,
  CreateObjectInput,
  DeleteObjectInput,
  ImportProjectArtifactsInput,
  MoveObjectInput,
  OperationalObject,
  TagDefinition,
  UpdateObjectInput,
} from "./types";

const isTauri = "__TAURI_INTERNALS__" in window;

let browserData: BoardData = structuredClone(mockBoardData);

function uniqueId(candidate: string, existingObjects: OperationalObject[]) {
  const base = slugify(candidate) || `object-${existingObjects.length + 1}`;
  if (!existingObjects.some((object) => object.id === base)) return base;
  let suffix = 2;
  while (existingObjects.some((object) => object.id === `${base}-${suffix}`)) suffix += 1;
  return `${base}-${suffix}`;
}

function withTagDefinitions(data: BoardData, tags: string[]) {
  const tagDefinitions = [...data.tagDefinitions];
  for (const tag of tags) {
    if (!tagDefinitions.some((definition) => definition.tag === tag)) {
      tagDefinitions.push({ tag, color: "#8b5cf6", description: null });
    }
  }
  return tagDefinitions.sort((a, b) => a.tag.localeCompare(b.tag));
}

function objectFromInput(input: CreateObjectInput, existingObjects: OperationalObject[]): OperationalObject {
  const definition = objectRegistry[input.objectType];
  const now = new Date().toISOString();
  const id = uniqueId(input.identity.id || input.identity.name, existingObjects);
  const cardOrder =
    Math.max(
      0,
      ...existingObjects
        .filter((object) => object.board.board === input.board.board && object.board.lane === input.board.lane)
        .map((object) => object.cardOrder),
    ) + 1;

  return {
    id,
    objectType: input.objectType,
    schema: definition.schema,
    schemaVersion: definition.schemaVersion,
    identity: {
      ...input.identity,
      id: input.identity.id || id,
      name: input.identity.name,
      summary: input.identity.summary,
    },
    board: input.board,
    metadata: {
      ...input.metadata,
      createdAt: now,
      updatedAt: now,
    },
    payload: input.payload,
    createdAt: now,
    updatedAt: now,
    cardOrder,
  } as OperationalObject;
}

export async function getBoardData(): Promise<BoardData> {
  if (!isTauri) return browserData;
  return invoke<BoardData>("get_board_data");
}

export async function createObject(input: CreateObjectInput): Promise<BoardData> {
  if (!isTauri) {
    const object = objectFromInput(input, browserData.objects);
    browserData = {
      ...browserData,
      tagDefinitions: withTagDefinitions(browserData, object.metadata.tags),
      objects: [...browserData.objects, object],
    };
    return browserData;
  }

  return invoke<BoardData>("create_object", { input });
}

export async function updateObject(update: UpdateObjectInput): Promise<BoardData> {
  if (!isTauri) {
    const now = new Date().toISOString();
    browserData = {
      ...browserData,
      tagDefinitions: withTagDefinitions(browserData, update.metadata.tags),
      objects: browserData.objects.map((object) =>
        object.id === update.id
          ? {
              ...object,
              identity: update.identity,
              board: update.board,
              metadata: {
                ...update.metadata,
                createdAt: object.metadata.createdAt,
                updatedAt: now,
              },
              payload: update.payload,
              updatedAt: now,
            } as OperationalObject
          : object,
      ),
    };
    return browserData;
  }

  return invoke<BoardData>("update_object", { update });
}

export async function moveObject(input: MoveObjectInput): Promise<BoardData> {
  if (!isTauri) {
    const now = new Date().toISOString();
    browserData = {
      ...browserData,
      objects: browserData.objects.map((object) =>
        object.id === input.objectId
          ? {
              ...object,
              board: {
                ...object.board,
                board: input.boardId,
                lane: input.laneId,
              },
              cardOrder: input.cardOrder,
              updatedAt: now,
              metadata: {
                ...object.metadata,
                updatedAt: now,
              },
            }
          : object,
      ),
    };
    return browserData;
  }

  return invoke<BoardData>("move_object", { input });
}

export async function deleteObject(input: DeleteObjectInput): Promise<BoardData> {
  if (!isTauri) {
    browserData = {
      ...browserData,
      objects: browserData.objects.filter((object) => object.id !== input.objectId),
      relationships: browserData.relationships.filter((relationship) => relationship.sourceId !== input.objectId && relationship.targetId !== input.objectId),
    };
    return browserData;
  }

  return invoke<BoardData>("delete_object", { input });
}

export async function pickArtifactFiles(): Promise<string[]> {
  if (!isTauri) {
    const path = window.prompt("Enter one artifact file path to attach to this project.");
    return path?.trim() ? [path.trim()] : [];
  }

  const selected = await openDialog({
    multiple: true,
    directory: false,
    title: "Import project artifacts",
  });
  if (!selected) return [];
  return Array.isArray(selected) ? selected : [selected];
}

export async function importProjectArtifacts(input: ImportProjectArtifactsInput): Promise<BoardData> {
  if (!isTauri) {
    const now = new Date().toISOString();
    const project = browserData.objects.find((object) => object.id === input.projectId && object.objectType === "project");
    if (!project) return browserData;
    const existingObjects = [...browserData.objects];
    const imported = input.sourcePaths.map((path, index) => {
      const normalizedPath = path.replaceAll("\\", "/");
      const filename = normalizedPath.split("/").filter(Boolean).at(-1) ?? "artifact";
      const name = filename.replace(/\.[^.]+$/, "") || filename;
      const extension = filename.includes(".") ? filename.split(".").at(-1)?.toLowerCase() || "file" : "file";
      const id = uniqueId(name, existingObjects);
      const artifact = {
        id,
        objectType: "artifact",
        schema: objectRegistry.artifact.schema,
        schemaVersion: objectRegistry.artifact.schemaVersion,
        identity: { id, name, summary: "" },
        board: { ...project.board },
        metadata: {
          tags: ["Artifact", "Project"],
          notes: "",
          createdAt: now,
          updatedAt: now,
        },
        payload: {
          classification: { kind: artifactKind(extension) },
          source: { path, format: extension, capturedAt: now },
          context: { version: "", batch: `${project.id}-artifact-import`, context: "Imported project artifact" },
          integrity: { sizeBytes: 0, hash: "", hashAlgorithm: "" },
          state: { current: true },
        },
        createdAt: now,
        updatedAt: now,
        cardOrder:
          Math.max(0, ...browserData.objects.filter((object) => object.board.board === project.board.board && object.board.lane === project.board.lane).map((object) => object.cardOrder)) +
          index +
          1,
      } as OperationalObject;
      existingObjects.push(artifact);
      return artifact;
    });
    browserData = {
      ...browserData,
      tagDefinitions: withTagDefinitions(browserData, ["Artifact", "Project"]),
      objects: [...browserData.objects, ...imported],
      relationships: [
        ...browserData.relationships,
        ...imported.map((artifact) => ({
          id: `${artifact.id}-belongs-to-${project.id}`,
          schema: "aptlantis.relationship" as const,
          schemaVersion: "0.1",
          sourceId: artifact.id,
          type: "belongs_to",
          targetId: project.id,
          status: "active",
          summary: `${artifact.identity.name} belongs to ${project.identity.name}`,
          required: false,
          notes: "",
          createdAt: now,
          updatedAt: now,
        })),
      ],
    };
    return browserData;
  }

  return invoke<BoardData>("import_project_artifacts", { input });
}

export async function updateTagDefinition(tagDefinition: TagDefinition): Promise<BoardData> {
  if (!isTauri) {
    const existing = browserData.tagDefinitions.some((item) => item.tag === tagDefinition.tag);
    browserData = {
      ...browserData,
      tagDefinitions: existing
        ? browserData.tagDefinitions.map((item) => (item.tag === tagDefinition.tag ? tagDefinition : item))
        : [...browserData.tagDefinitions, tagDefinition].sort((a, b) => a.tag.localeCompare(b.tag)),
    };
    return browserData;
  }

  return invoke<BoardData>("update_tag_definition", { tagDefinition });
}

export async function openPath(path: string): Promise<void> {
  if (!isTauri) {
    console.info("Open path requested:", path);
    return;
  }

  await invoke("open_path", { path });
}

function artifactKind(extension: string) {
  if (["png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff"].includes(extension)) return "screenshot";
  if (["pdf", "doc", "docx", "txt", "md", "rtf"].includes(extension)) return "document";
  if (["json", "toml", "yaml", "yml", "xml"].includes(extension)) return "manifest";
  if (["mp4", "mov", "webm", "mp3", "wav"].includes(extension)) return "recording";
  if (["zip", "7z", "tar", "gz", "msi", "msix", "exe"].includes(extension)) return "package";
  if (["html", "htm", "csv", "tsv", "xlsx"].includes(extension)) return "report";
  return "other";
}
