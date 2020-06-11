import React from "react"
import { Box, CSSGrid, Sans } from "@artsy/palette"
import { ProjectWithComparison } from "Typings"
import { ProjectSummary } from "./components/ProjectSummary"
import { MainLayout } from "components/MainLayout"

interface Projects {
  released_projects: [ProjectWithComparison]
  unreleased_projects: [ProjectWithComparison]
  projects: [ProjectWithComparison]
  params: any
}

export const ProjectsIndex: React.FC<Projects> = (props) => {
  const { released_projects, unreleased_projects } = props
  return (
    <MainLayout>
      <Box px={3}>
        <Sans size="8">Projects Index</Sans>
        <Box pb={3}>
          <Sans size="6">Out of sync</Sans>
          <ProjectSummaryGrid projects={unreleased_projects} />
        </Box>
        <Box pb={3}>
          <Sans size="6">Up to date</Sans>
          <ProjectSummaryGrid projects={released_projects} />
        </Box>
      </Box>
    </MainLayout>
  )
}

const ProjectSummaryGrid: React.FC<{
  projects: [ProjectWithComparison]
}> = ({ projects }) => {
  return (
    <CSSGrid
      gridTemplateColumns={["repeat(2, 1fr)", "repeat(4, 1fr)"]}
      gridGap={[2, 4]}
      my={2}
    >
      {projects.map(({ project, compared_stages, ordered_stages }, i) => (
        <ProjectSummary
          key={i}
          project={project}
          compared_stages={compared_stages}
          ordered_stages={ordered_stages}
        />
      ))}
    </CSSGrid>
  )
}
