import React from "react"
import ReactDOM from "react-dom"
import { ProjectShow } from "apps/Project"

document.addEventListener("turbolinks:load", () => {
  const node = document.getElementById("project_data")
  const props = JSON.parse((node && node.dataset.props) || "")

  ReactDOM.render(<ProjectShow {...props} />, node)
})
