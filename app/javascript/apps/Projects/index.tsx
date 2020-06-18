import { Box, CSSGrid, Sans } from "@artsy/palette"
import { MainLayout } from "../../components/MainLayout"
import { Project } from "Typings"
import { ProjectSummary } from "../../components/Project/ProjectSummary"
import React from "react"

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
  tags,
  params,
}) => {
  return (
    <MainLayout tags={tags}>
      <Box px={3} pt={2}>
        {params.tags && (
          <Sans size="8" pb={4} style={{ textTransform: "capitalize" }}>
            Team: {params.tags[0]}
          </Sans>
        )}
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
