import { Dependency, Tags, TagsList } from "Typings"
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

export const formattedTags = (tags: Tags): TagsList => {
  return tags.map((tag) => ({
    href: tagPath(tag),
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
