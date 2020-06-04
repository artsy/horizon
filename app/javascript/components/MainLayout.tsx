import React from "react"
import { Box, Link, Theme, Sans, Flex, ArtsyMarkIcon } from "@artsy/palette"

export const MainLayout = () => {
  return (
    <Theme>
      <NavBar />
    </Theme>
  )
}

export const NavBar = () => {
  return (
    <Box width="100%">
      <Link href="/" noUnderline display="inline-block">
        <Flex px={3} py={1} width="min-content">
          <ArtsyMarkIcon width="25" height="25" />
          <Sans size="5" weight="medium" pl={0.5}>
            Horizon
          </Sans>
        </Flex>
      </Link>
    </Box>
  )
}
