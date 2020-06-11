import { MainLayout, NavBar } from "../MainLayout"
import React from "react"
import { mount } from "enzyme"

describe("MainLayout", () => {
  it("Renders the nav bar", () => {
    const component = mount(<MainLayout />)
    expect(component.find(NavBar)).toHaveLength(1)
    expect(component.text()).toMatch("Horizon")
  })
})
