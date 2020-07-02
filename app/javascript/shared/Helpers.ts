import { Dependency, Project, Tags, TagsList } from "Typings"
import { tagPath } from "./UrlHelper"

export const getColorFromSeverity = (
  severity: number,
): "red100" | "yellow100" | undefined => {
  if (severity >= 10) {
    return "red100"
  } else if (severity >= 1) {
    return "yellow100"
  }
}

export const projectRequiresDependencyUpdates = ({
  dependencies,
}: Project): boolean => {
  return dependencies.filter((d) => d.updateRequired === true).length > 0
}

export const projectRequiresAutoDeploys = ({
  isAutoDeploy,
  isKubernetes,
}: Project): boolean => {
  return !isAutoDeploy && isKubernetes
}

export const projectRequiresRenovate = ({
  orbs,
  isKubernetes,
}: Project): boolean => {
  return orbs?.length > 0 || isKubernetes
}

export const isCircleCi = ({ ciProvider }: Project): boolean => {
  return ciProvider === "Circleci"
}

export const formattedTags = (tags: Tags): TagsList => {
  return tags.map((tag) => ({
    href: tagPath(tag),
    name: tag,
  }))
}

export const formattedOrbs = (tags: string[]): TagsList => {
  // FIXME: should go to a href
  return tags.map((tag) => ({
    href: "",
    name: tag,
  }))
}

export const formattedDependencies = (dependencies: Dependency[]): TagsList => {
  // FIXME: should go to a href
  return dependencies.map((dependency) => ({
    href: "",
    name: `${dependency.name} ${dependency.version}`,
  }))
}
