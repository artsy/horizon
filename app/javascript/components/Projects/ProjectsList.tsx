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
  isCircleCi,
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
          <Col xs={1} sm={1}>
            <Sans size="3t" weight="medium">
              Criticality
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
  const { block, deploymentType, id, name, severity, tags } = project

  return (
    <Row alignItems="center">
      <Separator />
      <Flex width="100px" data-test="severity">
        <SeverityIcon severity={severity} />
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

      <Col xs={1} sm={1} data-test="criticality">
        <CriticalityTag {...project} />
      </Col>

      <Col xs={2} sm={2}>
        {tags && <Tags tags={formattedTags(tags)} />}
      </Col>

      <Col xs={2} sm={2} data-test="dependencies">
        <DependenciesList {...project} />
      </Col>

      <Col xs={1} sm={1}>
        {deploymentType && (
          <Sans size="2" color="black60">
            {deploymentType}
          </Sans>
        )}
      </Col>

      <Col xs={1} sm={1} data-test="isAutoDeploy">
        <AutoDeployIcon {...project} />
      </Col>

      <Col xs={1} sm={1} data-test="renovate">
        <RenovateIcon {...project} />
      </Col>

      <Col xs={1} sm={1}>
        <OrbsList {...project} />
      </Col>
    </Row>
  )
}

const DependenciesList: React.FC<Project> = (props) => {
  const { dependencies, dependenciesUpToDate } = props
  const requiresDependencyUpdates = projectRequiresDependencyUpdates(props)
  const hasDependencies = dependencies?.length > 0

  if (!hasDependencies) return null

  return (
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
  )
}

const OrbsList: React.FC<Project> = (props) => {
  const { orbs, isKubernetes } = props
  const isCircle = isCircleCi(props)
  const hasOrbs = orbs?.length > 0

  return hasOrbs ? (
    <Tags tags={formattedOrbs(orbs)} />
  ) : isKubernetes ? (
    <XCircleIcon fill="red100" />
  ) : (
    <Sans size="2" color="black60">
      {isCircle && "N/A"}
    </Sans>
  )
}

const RenovateIcon: React.FC<Project> = (props) => {
  const { renovate } = props
  const requiresRenovate = projectRequiresRenovate(props)

  return renovate ? (
    <CircleBlackCheckIcon fill="green100" />
  ) : requiresRenovate ? (
    <XCircleIcon fill="red100" />
  ) : (
    <Sans size="2" color="black60">
      N/A
    </Sans>
  )
}

const SeverityIcon: React.FC<{ severity: number }> = ({ severity }) => {
  const releaseColor = getColorFromSeverity(severity)

  return severity === 0 ? (
    <CircleBlackCheckIcon fill="green100" />
  ) : (
    <XCircleIcon fill={releaseColor} />
  )
}

const AutoDeployIcon: React.FC<Project> = (props) => {
  const { isAutoDeploy } = props
  const requiresAutoDeploys = projectRequiresAutoDeploys(props)

  return isAutoDeploy ? (
    <CircleBlackCheckIcon fill="green100" />
  ) : requiresAutoDeploys ? (
    <XCircleIcon fill="red100" />
  ) : null
}

export const CriticalityTag: React.FC<Project> = ({ criticality }) => {
  let name
  switch (criticality) {
    case 3:
      name = "3: Critical"
      break
    case 2:
      name = "2: Important"
      break
    case 1:
      name = "1: Supported"
      break
    case 0:
      name = "0: Unsupported"
      break
  }

  return (
    <Tags
      tags={[
        {
          href: `/?criticality=${criticality}`,
          name: name,
        },
      ]}
    />
  )
}
