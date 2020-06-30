import {
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
  formattedTags,
  getColorFromSeverity,
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
    dependencies,
    id,
    isAutoDeploy,
    isKubernetes,
    name,
    orbs,
    severity,
    tags,
  } = project
  const releaseColor = getColorFromSeverity(severity)

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
      <Col xs={2} sm={2}>
        {dependencies && dependencies.length > 0 && (
          <Tags tags={formattedDependencies(dependencies)} />
        )}
      </Col>
      <Col xs={1} sm={1}>
        {isKubernetes && <Sans size="3t">Kubernetes</Sans>}
      </Col>
      <Col xs={1} sm={1} data-test="isAutoDeploy">
        {isAutoDeploy && <CircleBlackCheckIcon fill="green100" />}
        {!isAutoDeploy && isKubernetes && <XCircleIcon fill="red100" />}
      </Col>
      <Col xs={1} sm={1} data-test="renovate">
        {(orbs && orbs.length) || isKubernetes ? (
          project.renovate ? (
            <CircleBlackCheckIcon fill="green100" />
          ) : (
            <XCircleIcon fill="red100" />
          )
        ) : (
          <Sans size="2" color="black60">
            N/A
          </Sans>
        )}
      </Col>
      <Col xs={1} sm={1}>
        {orbs && orbs.length > 0 && (
          <Flex my={1} alignItems="center">
            <Tags tags={formattedTags(orbs)} />
          </Flex>
        )}
      </Col>
    </Row>
  )
}
