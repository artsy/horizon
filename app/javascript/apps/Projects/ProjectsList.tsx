import {
  Box,
  Button,
  CircleBlackCheckIcon,
  Col,
  Flex,
  Grid,
  Row,
  Sans,
  Separator,
  Tags,
  XCircleIcon,
} from "@artsy/palette"
import { formattedDependencies, formattedTags } from "apps/Project"
import { Project } from "Typings"
import React from "react"
import { getColorFromSeverity } from "components/Project/ProjectSummary"

export interface ProjectsProps {
  projects: Project[]
}

export const ProjectsList: React.FC<ProjectsProps> = ({ projects }) => {
  return (
    <Box>
      {projects && (
        <Box pb={4}>
          <ProjectSummaryList projects={projects} />
        </Box>
      )}
    </Box>
  )
}

export const ProjectSummaryList: React.FC<{
  projects: Project[]
}> = ({ projects }) => {
  return (
    <Grid fluid>
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

      {projects.map((project, i) => {
        const {
          block,
          dependencies,
          isAutoDeploy,
          isKubernetes,
          name,
          orbs,
          severity,
          tags,
        } = project
        const releaseColor = getColorFromSeverity(severity)

        return (
          <Row key={i} alignItems="center">
            <Separator />
            <Flex width="100px">
              {severity === 0 ? (
                <CircleBlackCheckIcon fill="green100" />
              ) : (
                <XCircleIcon fill={releaseColor} />
              )}
            </Flex>
            <Col xs={2} sm={2}>
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
            <Col xs={1} sm={1}>
              {isAutoDeploy && <CircleBlackCheckIcon fill="green100" />}
              {!isAutoDeploy && isKubernetes && <XCircleIcon fill="red100" />}
            </Col>
            <Col xs={1} sm={1}>
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
      })}
      <Separator />
    </Grid>
  )
}
