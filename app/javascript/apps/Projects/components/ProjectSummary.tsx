import { BorderBox, Box, Sans } from "@artsy/palette"
import { Project, Stage } from "Typings"
import { CommitsMessage } from "./StageCommitsMessage"
import React from "react"
import { StageName } from "./StageName"

export const ProjectSummary: React.FC<Project> = ({
  severity,
  name,
  description,
  comparedStages,
  orderedStages,
}) => {
  const borderColor = getColorFromSeverity(severity)
  const isAgedClass = (severity > 10 && "aged") || ""

  return (
    <BorderBox
      className={isAgedClass}
      flexDirection="column"
      borderColor={borderColor}
    >
      <Box>
        <Sans size="8">{name}</Sans>
        <Sans size="3t">{description}</Sans>
      </Box>

      <Box pt={1}>
        {orderedStages.map((stage: Stage, i: number) => {
          if (i === 0) {
            return null
          }
          const comparison = comparedStages[i - 1]
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
