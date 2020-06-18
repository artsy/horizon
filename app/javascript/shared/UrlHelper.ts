export const tagPath = (tag: string): string => {
  return `/projects?tags%5B%5D=${tag}`
}

export const deployBlockPath = (id: number): string => {
  return `/admin/deploy_blocks/${id.toString()}`
}

export const projectPath = (id: number): string => {
  return `projects/${id}`
}

export const projectEditPath = (id: number): string => {
  return `/admin/projects/${id.toString()}`
}
