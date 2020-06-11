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
  ordered_stages: [Stage]
  severity: number
  tags: Tags
}

export interface ProjectWithComparison {
  project: Project
  compared_stages: [ComparedStage]
  ordered_stages: [Stage]
}

export type TagsList = {
  href: string
  name: string
}[]
