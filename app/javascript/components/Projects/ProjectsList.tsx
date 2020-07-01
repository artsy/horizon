import {
  Box,
  Button,
  CircleBlackCheckIcon,
  Col,
  Flex,
  Grid,
  Link,
  Row,
  Sans,
  Separator,
  Tags,
  XCircleIcon,
} from "@artsy/palette"
import {
  formattedDependencies,
  formattedOrbs,
  formattedTags,
  getColorFromSeverity,
  projectRequiresAutoDeploys,
  projectRequiresDependencyUpdates,
  projectRequiresRenovate,
} from "../../shared/Helpers"
import { Project } from "Typings"
import React from "react"

export interface ProjectsProps {
  projects: Project[]
}

export const ProjectsList: React.FC<ProjectsProps> = ({ projects }) => {
  return (
    projects && (
      <Grid fluid pb={4}>
        <Row>
          <Flex width="100px">
            <Sans size="3t" weight="medium">
              Up to date
            </Sans>
          </Flex>
          <Col xs={2} sm={2}>
            <Sans size="3t" weight="medium">
              Project name
            </Sans>
          </Col>
          <Col xs={2} sm={2}>
            <Sans size="3t" weight="medium">
              Teams
            </Sans>
          </Col>
          <Col xs={2} sm={2}>
            <Sans size="3t" weight="medium">
              Dependencies
            </Sans>
          </Col>
          <Col xs={1} sm={1}>
            <Sans size="3t" weight="medium">
              Deployment
            </Sans>
          </Col>
          <Col xs={1} sm={1}>
            <Sans size="3t" weight="medium">
              Auto Deploy PR
            </Sans>
          </Col>
          <Col xs={1} sm={1}>
            <Sans size="3t" weight="medium">
              Renovate
            </Sans>
          </Col>
          <Col xs={1} sm={1}>
            <Sans size="3t" weight="medium">
              Orbs
            </Sans>
          </Col>
        </Row>

        {projects.map((project, i) => (
          <ProjectsListRow project={project} key={i} />
        ))}
        <Separator />
      </Grid>
    )
  )
}

export const ProjectsListRow: React.FC<{ project: Project }> = ({
  project,
}) => {
  const {
    block,
    ci_provider,
    dependencies,
    dependenciesUpToDate,
    id,
    isAutoDeploy,
    isKubernetes,
    name,
    orbs,
    renovate,
    severity,
    tags,
  } = project
  const releaseColor = getColorFromSeverity(severity)
  const requiresAutoDeploys = projectRequiresAutoDeploys(project)
  const requiresRenovate = projectRequiresRenovate(project)
  const requiresDependencyUpdates = projectRequiresDependencyUpdates(project)

  return (
    <Row alignItems="center">
      <Separator />
      <Flex width="100px" data-test="severity">
        {severity === 0 ? (
          <CircleBlackCheckIcon fill="green100" />
        ) : (
          <XCircleIcon fill={releaseColor} />
        )}
      </Flex>

      <Col xs={2} sm={2}>
        <Link href={`/projects/${id}`} underlineBehavior="none">
          <Flex alignItems="center">
            <Sans size="5t" my={1}>
              {name}
            </Sans>

            {block && (
              <Button size="small" ml={1}>
                Blocked
              </Button>
            )}
          </Flex>
        </Link>
      </Col>

      <Col xs={2} sm={2}>
        {tags && <Tags tags={formattedTags(tags)} />}
      </Col>

      <Col xs={2} sm={2} data-test="dependencies">
        {dependencies?.length > 0 && (
          <Flex alignItems="center">
            {dependenciesUpToDate ? (
              <CircleBlackCheckIcon fill="green100" />
            ) : (
              <XCircleIcon
                fill={requiresDependencyUpdates ? "red100" : "yellow100"}
              />
            )}
            <Box pr={1} />
            <Tags tags={formattedDependencies(dependencies)} />
          </Flex>
        )}
      </Col>

      <Col xs={1} sm={1}>
        {isKubernetes && <Sans size="3t">Kubernetes</Sans>}
      </Col>

      <Col xs={1} sm={1} data-test="isAutoDeploy">
        {isAutoDeploy && <CircleBlackCheckIcon fill="green100" />}
        {requiresAutoDeploys && <XCircleIcon fill="red100" />}
      </Col>

      <Col xs={1} sm={1} data-test="renovate">
        {renovate ? (
          <CircleBlackCheckIcon fill="green100" />
        ) : requiresRenovate ? (
          <XCircleIcon fill="red100" />
        ) : (
          <Sans size="2" color="black60">
            N/A
          </Sans>
        )}
      </Col>

      <Col xs={1} sm={1}>
        {orbs?.length > 0 ? (
          <Flex my={1} alignItems="center">
            <Tags tags={formattedOrbs(orbs)} />
          </Flex>
        ) : isKubernetes ? (
          <XCircleIcon fill="red100" />
        ) : (
          ci_provider !== "circleci" && (
            <Sans size="2" color="black60">
              N/A
            </Sans>
          )
        )}
      </Col>
    </Row>
  )
}
