export interface Stage {
  name: string
}

export interface Snapshot {
  description: [Commit]
}

export interface Commit {
  commit: string
  date: string
  firstName: string
  gravatar: string
  href: string
  message: string
}

export interface ComparedStage {
  stages: [Stage]
  score: number
  snapshot: Snapshot
}

export type Tags = [string]

export interface Project {
  description: string
  gitRemote: string
  id: string
  isBlocked: boolean
  isFullyReleased: boolean
  isKubernetes: boolean
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
