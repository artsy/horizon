import {
  ArtsyMarkIcon,
  Box,
  Flex,
  Link,
  Menu,
  MenuItem,
  Sans,
  Theme,
} from "@artsy/palette"
import React, { useState } from "react"
import { Tags } from "Typings"
import { tagPath } from "UrlHelper"

interface MainLayoutProps {
  tags?: Tags
}

export const MainLayout: React.FC<MainLayoutProps> = (props) => {
  return (
    <Theme>
      <NavBar {...props} />
      {props.children}
    </Theme>
  )
}

export const NavBar: React.FC<MainLayoutProps> = ({ tags }) => {
  return (
    <Box width="100%">
      <Flex justifyContent="space-between" px={3} alignItems="center">
        <Link href="/" noUnderline display="inline-block">
          <Flex py={1} width="min-content">
            <ArtsyMarkIcon width="25" height="25" />
            <Sans size="5" weight="medium" pl={0.5}>
              Horizon
            </Sans>
          </Flex>
        </Link>

        <Flex>
          <TagMenu tags={tags} />
          <Sans size="4t" weight="medium" pl={2}>
            <Link noUnderline href="/admin">
              Admin
            </Link>
          </Sans>
        </Flex>
      </Flex>
    </Box>
  )
}

export const TagMenu: React.FC<MainLayoutProps> = ({ tags }) => {
  if (!tags?.length) {
    return null
  }
  const [isVisible, setVisible] = useState(0)

  return (
    <Box position="relative" onMouseLeave={() => setVisible(0)}>
      <Sans size="4t" weight="medium" onMouseEnter={() => setVisible(1)}>
        <Link noUnderline>Teams</Link>
      </Sans>
      {isVisible !== 0 && (
        <Box
          position="absolute"
          right="0"
          zIndex="1"
          style={{ textTransform: "capitalize" }}
        >
          <Menu>
            {tags.map((tag, i) => (
              <MenuItem key={i} href={tagPath(tag)}>
                {tag}
              </MenuItem>
            ))}
          </Menu>
        </Box>
      )}
    </Box>
  )
}
