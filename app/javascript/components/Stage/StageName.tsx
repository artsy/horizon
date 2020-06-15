import { ComparedStage, Stage } from "Typings"
import { Flex, Sans } from "@artsy/palette"
import React from "react"
import { StageIcon } from "./StageIcon"

export const StageName: React.FC<{
  stage: Stage
  comparison?: ComparedStage
}> = ({ stage, comparison = {} }) => {
  return (
    <Flex alignItems="end">
      <StageIcon score={comparison.score} />
      <Sans size="5t" style={{ textTransform: "capitalize" }} pl={1}>
        {stage.name}
      </Sans>
    </Flex>
  )
}
