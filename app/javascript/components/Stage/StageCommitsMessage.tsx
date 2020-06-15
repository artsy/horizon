import { ComparedStage } from "Typings"
import React from "react"
import { Sans } from "@artsy/palette"

export const CommitsMessage: React.FC<ComparedStage> = ({
  blame,
  snapshot,
}) => {
  const count = snapshot ? snapshot.description.length : 0
  let message = "Up to date"
  if (count > 1) {
    message = `${count} commits behind`
  } else if (count === 1) {
    message = "1 commit behind"
  }

  return <Sans size="3t">{message}</Sans>
}
