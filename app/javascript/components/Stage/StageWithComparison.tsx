import { Box, Flex, ReadMore, Sans, StackableBorderBox } from "@artsy/palette"
import { ComparedStage, Stage } from "Typings"
import { CommitsMessage } from "./StageCommitsMessage"
import React from "react"
import { StageName } from "./StageName"

export const StageWithComparison: React.FC<{
  stage: Stage
  comparison?: ComparedStage
}> = ({ comparison = {} as ComparedStage, stage }) => {
  const diff = comparison.snapshot && comparison.snapshot.description

  return (
    <StackableBorderBox flexDirection="column">
      <Flex justifyContent="space-between">
        <StageName comparison={comparison} stage={stage} />
        <CommitsMessage {...comparison} />
      </Flex>

      {diff && diff.length > 0 && (
        <Sans size="3t" pl={35} pt={1}>
          <ReadMore
            maxChars={350}
            content={
              <Box>
                {diff.map((commit, i) => (
                  <Box mb={1} key={i}>
                    <li>{commit}</li>
                  </Box>
                ))}
              </Box>
            }
          />
        </Sans>
      )}
    </StackableBorderBox>
  )
}
