import { MainLayout, NavBar } from "../MainLayout"
import React from "react"
import { Tags } from "Typings"
import { mount } from "enzyme"

describe("MainLayout", () => {
  it("Renders the nav bar", () => {
    const component = mount(<MainLayout />)
    expect(component.find(NavBar)).toHaveLength(1)
    expect(component.text()).toMatch("Horizon")
    expect(component.text()).not.toMatch("Teams")
  })

  it("Renders 'teams' dropdown if tags are provided", () => {
    const component = mount(
      <MainLayout tags={["platform", "galleries"] as Tags} />,
    )
    expect(component.text()).toMatch("Teams")
  })
})
