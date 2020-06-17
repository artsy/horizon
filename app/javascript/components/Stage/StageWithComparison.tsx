import { Box, Flex, Separator, StackableBorderBox } from "@artsy/palette"
import { ComparedStage, Stage } from "Typings"
import { CommitSummary } from "./StageCommitsSummary"
import { CommitsMessage } from "./StageCommitsMessage"
import React from "react"
import { StageName } from "./StageName"

export const StageWithComparison: React.FC<{
  stage: Stage
  comparison?: ComparedStage
}> = ({ comparison = {} as ComparedStage, stage }) => {
  const { diff } = comparison
  return (
    <StackableBorderBox flexDirection="column">
      <Flex justifyContent="space-between">
        <StageName comparison={comparison} stage={stage} />
        <CommitsMessage {...comparison} />
      </Flex>

      {diff && diff.length > 0 && (
        <Box>
          <Separator my={2} />
          {diff.map((commit, i) => (
            <CommitSummary {...commit} key={i} />
          ))}
        </Box>
      )}
    </StackableBorderBox>
  )
}
