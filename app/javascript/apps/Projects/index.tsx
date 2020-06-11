import React from "react"
import { Box, CSSGrid, Sans } from "@artsy/palette"
import { Project } from "Typings"
import { ProjectSummary } from "./components/ProjectSummary"
import { MainLayout } from "components/MainLayout"

interface Projects {
  releasedProjects: [Project]
  unreleasedProjects: [Project]
  projects: [Project]
  params: any
}

export const ProjectsIndex: React.FC<Projects> = (props) => {
  const { releasedProjects, unreleasedProjects } = props
  return (
    <MainLayout>
      <Box px={3} pt={2}>
        <Box pb={4}>
          <Sans size="6">Out of sync</Sans>
          <ProjectSummaryGrid projects={unreleasedProjects} />
        </Box>
        <Box pb={4}>
          <Sans size="6">Up to date</Sans>
          <ProjectSummaryGrid projects={releasedProjects} />
        </Box>
      </Box>
    </MainLayout>
  )
}

const ProjectSummaryGrid: React.FC<{
  projects: [Project]
}> = ({ projects }) => {
  return (
    <CSSGrid
      gridTemplateColumns={["repeat(2, 1fr)", "repeat(4, 1fr)"]}
      gridGap={[2, 4]}
      my={2}
    >
      {projects.map((project, i) => (
        <ProjectSummary key={i} {...project} />
      ))}
    </CSSGrid>
  )
}
