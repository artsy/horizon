export const tagPath = (tag: string): string => {
  return `/projects?tags%5B%5D=${tag}`
}

export const deployBlockPath = (id: string): string => {
  return `/admin/deploy_blocks/${id}`
}

export const projectEditPath = (id: string): string => {
  return `/admin/projects/${id}`
}
