import { ArtsyMarkIcon, Box, Flex, Link, Sans, Theme } from "@artsy/palette"
import React from "react"

export const MainLayout: React.FC = (props: any) => {
  return (
    <Theme>
      <NavBar />
      {props.children}
    </Theme>
  )
}

export const NavBar: React.FC = () => {
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
