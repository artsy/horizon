import { ProjectsIndex } from "apps/Projects"
import React from "react"
import ReactDOM from "react-dom"

document.addEventListener("turbolinks:load", () => {
  const node = document.getElementById("projects_data")
  const props = JSON.parse((node && node.dataset.props) || "")

  ReactDOM.render(<ProjectsIndex {...props} />, node)
})
