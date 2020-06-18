export interface Block {
  created_at: string
  description: string
  id: number
  project_id: number
  resolved_at: string | null
  updated_at: string
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
  diff: Commit[]
  score: number
  snapshot: Snapshot
  stages: Stage[]
}

export interface Project {
  created_at: string
  description: string
  gitRemote: string
  id: number
  block: Block
  isFullyReleased: boolean
  isKubernetes: boolean
  name: string
  comparedStages: ComparedStage[]
  orderedStages: Stage[]
  organization_id: number
  severity: number
  snapshot_id: number
  tags: Tags
  updated_at: string
}

export interface Stage {
  branch: string | null
  created_at: string
  git_remote: string
  hokusai: string | null
  id: number
  name: string
  position: number
  profile_id: number
  project_id: number
  tag_pattern: string | null
  updated_at: string
}

export interface Snapshot {
  ahead_stage_id: number
  behind_stage_id: number
  created_at: string
  description: string[]
  id: number
  position: number
  released: boolean
  snapshot_id: number
  updated_at: string
}

export type Tags = string[]

export type TagsList = {
  href: string
  name: string
}[]
