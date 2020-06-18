import { BorderBox, Box, Button, Link, Sans } from "@artsy/palette"
import { Project, Stage } from "Typings"
import { CommitsMessage } from "components/Stage/StageCommitsMessage"
import React from "react"
import { StageName } from "components/Stage/StageName"

export const ProjectSummary: React.FC<Project> = ({
  comparedStages,
  description,
  id,
  block,
  name,
  orderedStages,
  severity,
}) => {
  const borderColor = getColorFromSeverity(severity)
  const isAgedClass = (severity > 10 && "aged") || ""

  return (
    <BorderBox
      className={isAgedClass}
      flexDirection="column"
      borderColor={borderColor}
      position="relative"
    >
      <Link href={`projects/${id}`} underlineBehavior="none">
        {block && (
          <Box position="absolute" right={3}>
            <Button variant="primaryBlack" size="small">
              Blocked
            </Button>
          </Box>
        )}
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
              <Box key={i} py={1}>
                <StageName comparison={comparison} stage={stage} />
                <Box pl={30}>
                  <CommitsMessage {...comparison} />

                  {comparison.blame && (
                    <Sans size="3t">{comparison.blame}</Sans>
                  )}
                </Box>
              </Box>
            )
          })}
        </Box>
      </Link>
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
