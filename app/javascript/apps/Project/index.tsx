import {
  Box,
  Button,
  CheckIcon,
  CloseIcon,
  EditIcon,
  Flex,
  Link,
  LockIcon,
  Sans,
  Separator,
  Tags,
} from "@artsy/palette"
import { Project, Stage, Tags as TagsType } from "Typings"
import { deployBlockPath, projectEditPath } from "../../shared/UrlHelper"
import { formattedDependencies, formattedTags } from "../../shared/Helpers"
import { MainLayout } from "../../components/MainLayout"
import { ProjectMaintenanceRecommendations } from "../../components/Project/ProjectMaintenanceRecommendations"
import React from "react"
import { StageWithComparison } from "../../components/Stage/StageWithComparison"
import styled from "styled-components"

const titleizeStyles = { textTransform: "capitalize" }
export interface ProjectShowProps {
  project: Project
  tags: TagsType
}

export const ProjectShow: React.FC<ProjectShowProps> = ({ project, tags }) => {
  const {
    block,
    ci_provider,
    comparedStages,
    dependencies,
    description,
    gitRemote,
    isKubernetes,
    maintenanceMessages,
    name,
    orbs,
    orderedStages,
    renovate,
    severity,
  } = project
  const isAgedClass = (severity >= 500 && "aged") || ""
  const blockLink = block && deployBlockPath(block.id)
  const gitLink = gitRemote && gitRemote.replace(".git", "")

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
          <Sans size="10" element="h1" style={titleizeStyles}>
            {name}
          </Sans>
          <Sans size="3">{description}</Sans>

          <Box position="absolute" right={3} top={3}>
            <EditLink
              href={projectEditPath(project.id)}
              underlineBehavior="hover"
            >
              <Flex alignItems="center">
                <Sans size="3t" weight="medium" pr={0.5}>
                  Edit
                </Sans>
                <EditIcon />
              </Flex>
            </EditLink>
          </Box>

          {gitLink && (
            <Box mt={1} mb={3}>
              <Sans size="3">
                <Link href={gitLink} underlineBehavior="hover">
                  {gitLink}
                </Link>
              </Sans>
            </Box>
          )}

          {block && (
            <>
              <Separator mb={3} />
              <Flex alignItems="center" mb={2}>
                <Button variant="primaryBlack" mr={1} mb={1}>
                  <Link
                    href={blockLink}
                    color="white100"
                    underlineBehavior="none"
                  >
                    <Flex>
                      {/** @ts-ignore */}
                      <LockIcon fill="white100" mr={0.5} />
                      Blocked
                    </Flex>
                  </Link>
                </Button>
                <Sans size="3t">
                  <Link href={blockLink} underlineBehavior="hover">
                    {block.description}
                  </Link>
                </Sans>
              </Flex>
            </>
          )}
        </Box>

        {maintenanceMessages.length > 0 && (
          <>
            <Separator mb={3} />
            <ProjectMaintenanceRecommendations project={project} />
          </>
        )}

        <Box mb={3}>
          {orderedStages.map((stage: Stage, i: number) => {
            const comparison = i > 0 ? comparedStages[i - 1] : undefined
            return (
              <StageWithComparison
                stage={stage}
                comparison={comparison}
                key={i}
              />
            )
          })}
        </Box>

        <Box>
          {project.tags && project.tags.length > 0 && (
            <Flex my={1} alignItems="center">
              <Sans size="3t" weight="medium" pr={1}>
                Teams
              </Sans>
              <Tags tags={formattedTags(project.tags)} />
            </Flex>
          )}

          {dependencies && dependencies.length > 0 && (
            <Flex my={1} alignItems="center">
              <Sans size="3t" weight="medium" pr={1}>
                Dependencies
              </Sans>
              <Tags tags={formattedDependencies(dependencies)} />
            </Flex>
          )}

          {orbs && orbs.length > 0 && (
            <Flex my={1} alignItems="center">
              <Sans size="3t" weight="medium" pr={1}>
                Orbs
              </Sans>
              <Tags tags={formattedTags(orbs)} />
            </Flex>
          )}

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

          {ci_provider && (
            <Flex my={1} alignItems="center">
              <Sans size="3t" weight="medium" pr={1}>
                CI Provider
              </Sans>
              <Flex my={1}>
                {ci_provider === "circleci" ? (
                  <CheckIcon fill="green100" />
                ) : (
                  <CloseIcon fill="red100" />
                )}
                <Sans size="3t" style={titleizeStyles}>
                  {ci_provider}
                </Sans>
              </Flex>
            </Flex>
          )}

          {renovate && (
            <Flex my={1} alignItems="center">
              <Sans size="3t" weight="medium" pr={1}>
                Bots
              </Sans>
              <Flex my={1}>
                <CheckIcon fill="green100" />
                <Sans size="3t">Renovate</Sans>
              </Flex>
            </Flex>
          )}
        </Box>
      </Box>
    </MainLayout>
  )
}

export const EditLink = styled(Link)``
