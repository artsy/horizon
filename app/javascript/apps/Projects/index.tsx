import { MainLayout } from "components/MainLayout"
import React from "react"
import { Tags } from "Typings"

interface Projects {
  tags: Tags
}

export const ProjectsIndex: React.FC<Projects> = ({ tags }) => {
  return <MainLayout tags={tags} />
}
