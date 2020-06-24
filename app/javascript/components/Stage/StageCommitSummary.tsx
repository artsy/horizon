import { Box, Flex, Link, Sans } from "@artsy/palette"
import { Commit } from "Typings"
import React from "react"

export const CommitSummary: React.FC<Commit> = ({
  date,
  firstName,
  gravatar,
  href,
  message,
}) => {
  return (
    <Sans size="3t" pt={1}>
      <Link href={href} target="blank" underlineBehavior="hover">
        <Flex>
          <Flex>
            <img
              src={gravatar}
              width="20px"
              height="20px"
              style={{ borderRadius: "50%" }}
            />
            <Box mr={1} ml={1}>
              {firstName}
            </Box>
            <Box mr={1}>{date}</Box>
          </Flex>

          <Box mr={1}>{message}</Box>
        </Flex>
      </Link>
    </Sans>
  )
}
