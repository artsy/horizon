import { CheckCircleFillIcon, XCircleIcon } from "@artsy/palette"
import React from "react"

export const StageIcon: React.FC<{ score?: number; size?: number }> = ({
  score = 0,
  size = 20,
}) => {
  if (score < 1) {
    return <CheckCircleFillIcon fill="green100" height={size} width={size} />
  } else {
    return (
      <XCircleIcon
        fill={score < 10 ? "yellow100" : "red100"}
        height={size + 1}
        width={size + 1} // This icon's height is inconsistent
      />
    )
  }
}
