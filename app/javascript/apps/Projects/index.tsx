import { Box, Button, Flex, Sans } from "@artsy/palette"
import React, { useState } from "react"
import { MainLayout } from "../../components/MainLayout"
import { Project } from "Typings"
import { ProjectsGrid } from "../../components/Projects/ProjectsGrid"
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
  const [isListView, setListView] = useState(params.view == "list" || false)

  return (
    <MainLayout tags={tags}>
      <Box px={3} pt={2}>
        <Flex justifyContent="space-between" mb={1}>
          <Box>
            {params.tags && (
              <Sans size="8" pb={4} style={{ textTransform: "capitalize" }}>
                Team: {params.tags[0]}
              </Sans>
            )}
          </Box>
          <Button
            variant="secondaryOutline"
            onClick={() => setListView(!isListView)}
          >
            {isListView ? "Grid" : "List"} view
          </Button>
        </Flex>

        {isListView ? (
          <ProjectsList projects={projects} />
        ) : (
          <ProjectsGrid
            releasedProjects={releasedProjects}
            unreleasedProjects={unreleasedProjects}
          />
        )}
      </Box>
    </MainLayout>
  )
}
