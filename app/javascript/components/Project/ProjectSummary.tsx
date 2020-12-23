import { BorderBox, Box, Button, Link, Sans } from "@artsy/palette"
import { Project, Stage } from "Typings"
import { CommitsMessage } from "../Stage/StageCommitsMessage"
import React from "react"
import { StageName } from "../Stage/StageName"
import { getColorFromSeverity } from "../../shared/Helpers"
import { projectPath } from "../../shared/UrlHelper"

export const ProjectSummary: React.FC<Project> = ({
  comparedStages,
  description,
  id,
  block,
  name,
  stages,
  severity,
  errorMessage,
}) => {
  const borderColor = getColorFromSeverity(severity)
  const isAgedClass = (severity >= 500 && "aged") || ""

  return (
    <BorderBox
      className={isAgedClass}
      flexDirection="column"
      borderColor={borderColor}
      position="relative"
    >
      <Link href={projectPath(id)} underlineBehavior="none">
        {block && (
          <Box position="absolute" right={3}>
            <Button variant="primaryBlack" size="small">
              Blocked
            </Button>
          </Box>
        )}
        <Box>
          <Sans size="8">{name}</Sans>
          {description && <Sans size="3t">{description}</Sans>}
          {errorMessage && (
            <Sans size="3t" color="red100">
              {errorMessage}
            </Sans>
          )}
        </Box>

        <Box pt={1}>
          {stages.map((stage: Stage, i: number) => {
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
