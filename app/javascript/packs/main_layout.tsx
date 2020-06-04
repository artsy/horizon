import { MainLayout } from "components/MainLayout"
import React from "react"
import ReactDOM from "react-dom"

document.addEventListener("turbolinks:load", () => {
  ReactDOM.render(<MainLayout />, document.getElementById("main-layout"))
})
