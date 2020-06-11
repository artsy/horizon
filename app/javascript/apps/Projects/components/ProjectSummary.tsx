import { BorderBox, Box, Sans } from "@artsy/palette"
import { ProjectWithComparison, Stage } from "Typings"
import { CommitsMessage } from "./StageCommitsMessage"
import React from "react"
import { StageName } from "./StageName"

export const ProjectSummary: React.FC<ProjectWithComparison> = ({
  project,
  compared_stages,
  ordered_stages,
}) => {
  const borderColor = getColorFromSeverity(project.severity)

  return (
    <BorderBox flexDirection="column" borderColor={borderColor}>
      <Box>
        <Sans size="8" style={{ textTransform: "capitalize" }}>
          {project.name}
        </Sans>
        <Sans size="3t">{project.description}</Sans>
      </Box>

      <Box pt={1}>
        {ordered_stages.map((stage: Stage, i: number) => {
          if (i === 0) {
            return null
          }
          const comparison = compared_stages[i - 1]
          return (
            <Box key={i} pt={1}>
              <StageName comparison={comparison} stage={stage} />
              <Box pl={30}>
                <CommitsMessage snapshot={comparison.snapshot} />
              </Box>
            </Box>
          )
        })}
      </Box>
    </BorderBox>
  )
}

export const getColorFromSeverity = (severity: number): string | undefined => {
  if (severity > 10) {
    return "red100"
  } else if (severity > 1) {
    return "yellow100"
  }
}
