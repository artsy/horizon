import React from "react";
import ReactDOM from "react-dom";
import { Box, Link, ArtsyMarkBlackIcon, Sans, Flex } from "@artsy/palette";

const Nav = () => (
  <Box px={30} py={10}>
    <Link href="/" underlineBehavior="hover">
      <Flex>
        <ArtsyMarkBlackIcon height={30} width={30} pr={2} />
        <Sans size="8">Horizon</Sans>
      </Flex>
    </Link>
  </Box>
);

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(<Nav name="React" />, document.getElementById("react"));
});
