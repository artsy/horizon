import {
  Box,
  Button,
  CheckIcon,
  Flex,
  Link,
  LockIcon,
  Sans,
  Tags,
} from "@artsy/palette"
import { Project, Stage, TagsList, Tags as TagsType } from "Typings"
import { MainLayout } from "components/MainLayout"
import { StageWithComparison } from "components/Stage/StageWithComparison"
import { tagPath } from "UrlHelper"
import React from "react"

export const ProjectShow: React.FC<{ project: Project; tags: TagsType }> = ({
  project,
  tags,
}) => {
  const {
    comparedStages,
    description,
    gitRemote,
    isBlocked,
    isKubernetes,
    name,
    severity,
    orderedStages,
  } = project
  const isAgedClass = (severity > 10 && "aged") || ""
  return (
    <MainLayout tags={tags}>
      <Box
        px={3}
        py={3}
        maxWidth={1080}
        mx="auto"
        position="relative"
        className={isAgedClass}
      >
        <Box mb={1}>
          <Sans size="10" style={{ textTransform: "capitalize" }}>
            {name}
          </Sans>
          <Sans size="3">{description}</Sans>

          {isBlocked && (
            <Box position="absolute" right={3} top={3}>
              <Button variant="primaryBlack">
                <Flex>
                  <LockIcon fill="white100" />
                  Blocked
                </Flex>
              </Button>
            </Box>
          )}

          {gitRemote && (
            <Box my={1}>
              <Sans size="3">
                <Link href={gitRemote}>{gitRemote}</Link>
              </Sans>
            </Box>
          )}

          <Flex my={1} alignItems="center">
            <Sans size="3t" weight="medium" pr={1}>
              Teams
            </Sans>
            <Tags tags={formattedTags(project.tags)} />
          </Flex>

          {isKubernetes && (
            <Flex my={1} alignItems="center">
              <Sans size="3t" weight="medium" pr={1}>
                Deployment
              </Sans>
              <Flex my={1}>
                <CheckIcon fill="green100" />
                <Sans size="3t">Kubernetes</Sans>
              </Flex>
            </Flex>
          )}
        </Box>

        <Box mb={1}>
          {orderedStages.map((stage: Stage, i: number) => {
            const comparison = i > 1 ? comparedStages[i - 1] : undefined
            return (
              <StageWithComparison
                stage={stage}
                comparison={comparison}
                key={i}
              />
            )
          })}
        </Box>
      </Box>
    </MainLayout>
  )
}

export const formattedTags = (tags: TagsType): TagsList => {
  return tags.map((tag) => ({
    href: tagPath(tag),
    name: tag,
  }))
}
