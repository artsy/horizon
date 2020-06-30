import { Box, Button, CSSGrid, Flex, Sans } from "@artsy/palette"
import React, { useState } from "react"
import { MainLayout } from "../../components/MainLayout"
import { Project } from "Typings"
import { ProjectSummary } from "../../components/Project/ProjectSummary"
import { ProjectsList } from "../../components/Projects/ProjectsList"

export interface ProjectsProps {
  releasedProjects: Project[]
  unreleasedProjects: Project[]
  projects: Project[]
  params: any
  tags: string[]
}

export const ProjectsIndex: React.FC<ProjectsProps> = ({
  releasedProjects,
  unreleasedProjects,
  projects,
  tags,
  params,
}) => {
  const [isListView, setListView] = useState(false)
  const ProjectsViewSwitcher = () => {
    return (
      <Flex justifyContent="flex-end" mb={1}>
        <Button
          variant="secondaryOutline"
          onClick={() => setListView(!isListView)}
        >
          {isListView ? "Grid" : "List"} view
        </Button>
      </Flex>
    )
  }

  return (
    <MainLayout tags={tags}>
      <Box px={3} pt={2}>
        {params.tags && (
          <Sans size="8" pb={4} style={{ textTransform: "capitalize" }}>
            Team: {params.tags[0]}
          </Sans>
        )}
        {ProjectsViewSwitcher()}
        {isListView ? (
          <ProjectsList projects={projects} />
        ) : (
          <>
            {unreleasedProjects && (
              <Box pb={4}>
                <Sans size="6">Out of sync</Sans>
                <ProjectSummaryGrid projects={unreleasedProjects} />
              </Box>
            )}
            {releasedProjects && (
              <Box pb={4}>
                <Sans size="6">Up to date</Sans>
                <ProjectSummaryGrid projects={releasedProjects} />
              </Box>
            )}
          </>
        )}
      </Box>
    </MainLayout>
  )
}

export const ProjectSummaryGrid: React.FC<{
  projects: Project[]
}> = ({ projects }) => {
  return (
    <CSSGrid
      gridTemplateColumns={[
        "repeat(2, 1fr)",
        "repeat(3, 1fr)",
        "repeat(4, 1fr)",
      ]}
      gridGap={[2, 4]}
      my={2}
    >
      {projects.map((project, i) => (
        <ProjectSummary key={i} {...project} />
      ))}
    </CSSGrid>
  )
}
