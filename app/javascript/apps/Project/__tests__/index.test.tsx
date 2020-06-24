import { Button, StackableBorderBox, Tags } from "@artsy/palette"
import { EditLink, ProjectShow, ProjectShowProps } from "../index"
import { NavBar } from "../../../components/MainLayout"
import React from "react"
import { mount } from "enzyme"
import { unreleasedProjectFixture } from "../../../fixtures/project"

describe("ProjectShow", () => {
  let props: ProjectShowProps
  const getWrapper = (passedProps = props) => {
    return mount(<ProjectShow {...passedProps} />)
  }

  beforeEach(() => {
    props = {
      project: unreleasedProjectFixture,
      tags: ["platform", "galleries"],
    }
  })

  it("renders main nav bar", () => {
    const component = getWrapper()
    expect(component.find(NavBar).text()).toMatch("Team")
  })

  it("renders the project name", () => {
    const component = getWrapper()
    expect(component.find("h1").text()).toMatch("Force")
  })

  it("renders project edit link", () => {
    const component = getWrapper()
    const editLink = component.find(EditLink).first()
    expect(editLink.text()).toMatch("Edit")
    expect(editLink.props().href).toBe("/admin/projects/11")
  })

  it("renders the git url", () => {
    const component = getWrapper()
    expect(component.text()).toMatch("https://github.com/artsy/force")
  })

  it("renders block if provided", () => {
    const component = getWrapper()
    expect(component.find(Button).first().text()).toMatch("Blocked")
    expect(component.text()).toMatch(
      "Something happened and we can't deploy the project.",
    )
  })

  it("renders stages", () => {
    const component = getWrapper()
    expect(component.find(StackableBorderBox).at(0).text()).toMatch("master")
    expect(component.find(StackableBorderBox).at(0).text()).toMatch(
      "Up to date",
    )
    expect(component.find(StackableBorderBox).at(1).text()).toMatch("staging")
    expect(component.find(StackableBorderBox).at(1).text()).toMatch(
      "Up to date",
    )
    expect(component.find(StackableBorderBox).at(2).text()).toMatch(
      "production",
    )
    expect(component.find(StackableBorderBox).at(2).text()).toMatch(
      "1 commit behind",
    )
  })

  it("renders teams", () => {
    const component = getWrapper()
    expect(component.find(Tags).at(0).text()).toMatch("platform")
  })

  it("renders deployments if kubernetes", () => {
    const component = getWrapper()
    expect(component.text()).toMatch("Kubernetes")
  })
})
