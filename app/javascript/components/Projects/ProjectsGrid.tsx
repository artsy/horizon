import { Box, CSSGrid, Sans } from "@artsy/palette"
import { Project } from "Typings"
import { ProjectSummary } from "../../components/Project/ProjectSummary"
import React from "react"

export interface ProjectsGridProps {
  releasedProjects: Project[]
  unreleasedProjects: Project[]
}

export const ProjectsGrid: React.FC<ProjectsGridProps> = ({
  releasedProjects,
  unreleasedProjects,
}) => {
  return (
    <Box>
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
