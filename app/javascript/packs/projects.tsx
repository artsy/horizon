import { ProjectsIndex } from "apps/Projects"
import React from "react"
import ReactDOM from "react-dom"

document.addEventListener("turbolinks:load", () => {
  const node = document.getElementById("projects_data")
  const props = JSON.parse((node && node.getAttribute("data")) || "")

  ReactDOM.render(
    <ProjectsIndex {...props} />,
    document.getElementById("react-body"),
  )
})
