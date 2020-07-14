export interface Block {
  created_at: string
  description: string
  id: number
  project_id: number
  resolved_at: string | null
  updated_at: string
}

export type CiProvider = "Circleci" | "Travis"

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

export interface Dependency {
  id: number
  name: string
  version: string
  updateRequired: boolean
}

export interface Project {
  block?: Block | null
  ciProvider: CiProvider
  comparedStages: ComparedStage[]
  criticality: 0 | 1 | 2 | 3
  description?: string
  dependencies: Dependency[]
  dependenciesUpToDate: boolean
  deploymentType?: "Kubernetes" | "Heroku"
  gitRemote?: string
  id: number
  isAutoDeploy: boolean
  isFullyReleased: boolean
  isKubernetes: boolean
  maintenanceMessages: string[]
  name: string
  orbs: Orb[]
  stages: Stage[]
  renovate: boolean
  severity: number
  tags?: Tags
}

export type Orb = "hokusai" | "yarn"

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
