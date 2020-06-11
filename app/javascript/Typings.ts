export interface Stage {
  name: string
}

export interface Snapshot {
  description: [string]
}

export interface ComparedStage {
  stages: [Stage]
  score: number
  snapshot: Snapshot
}

export type Tags = [string]

export interface Project {
  description: string
  git_remote: string
  id: string
  name: string
  comparedStages: [ComparedStage]
  orderedStages: [Stage]
  severity: number
  tags: Tags
}

export type TagsList = {
  href: string
  name: string
}[]
