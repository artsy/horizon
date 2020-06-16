import { ProjectShow } from "apps/Project"
import React from "react"
import ReactDOM from "react-dom"

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("project_data")
  const props = JSON.parse((node && node.dataset.props) || "")

  ReactDOM.render(<ProjectShow {...props} />, node)
})
