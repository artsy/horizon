// FIXME: incomplete
export interface Stage {
  name: string
}

export interface Snapshot {
  description: [Commit]
}

export interface Block {
  description: string
  id: string
  project_id: string
  resolved_at?: string
}

export interface Commit {
  date: string
  firstName: string
  gravatar: string
  href: string
  message: string
  sha: string
}

export interface ComparedStage {
  blame: string
  diff: [Commit]
  score: number
  snapshot: Snapshot
  stages: [Stage]
}

export interface Project {
  description: string
  gitRemote: string
  id: string
  block: Block
  isFullyReleased: boolean
  isKubernetes: boolean
  name: string
  comparedStages: [ComparedStage]
  orderedStages: [Stage]
  severity: number
  tags: Tags
}

export type Tags = string[]

export type TagsList = {
  href: string
  name: string
}[]
