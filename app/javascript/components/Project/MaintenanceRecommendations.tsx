import { Box, Sans } from "@artsy/palette"
import { Project } from "Typings"
import React from "react"

export const ProjectMaintenanceRecomendations: React.FC<{
  project: Project
}> = ({ project: { maintenanceMessages } }) => {
  return (
    <Box mb={3}>
      <Sans size="6">Maintenance recomended</Sans>
      {maintenanceMessages.map((message, i) => (
        <Sans size="3" key={i}>
          <li>{message}</li>
        </Sans>
      ))}
    </Box>
  )
}
