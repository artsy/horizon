import { Button, StackableBorderBox, Tags } from "@artsy/palette"
import { EditLink, ProjectShow, ProjectShowProps } from "../index"
import { NavBar } from "../../../components/MainLayout"
import React from "react"
import { mount } from "enzyme"
import { unreleasedProjectFixture } from "../../../fixtures/project"

describe("ProjectShow", () => {
  let props: ProjectShowProps
  let component
  const getWrapper = (passedProps = props) => {
    return mount(<ProjectShow {...passedProps} />)
  }

  beforeEach(() => {
    props = {
      project: unreleasedProjectFixture,
      tags: ["platform", "galleries"],
    }
    component = getWrapper()
  })

  it("renders main nav bar", () => {
    expect(component.find(NavBar).text()).toMatch("Team")
  })

  it("renders the project name", () => {
    expect(component.find("h1").text()).toMatch("Force")
  })

  it("renders project edit link", () => {
    const editLink = component.find(EditLink).first()
    expect(editLink.text()).toMatch("Edit")
    expect(editLink.props().href).toBe("/admin/projects/11")
  })

  it("renders the git url", () => {
    expect(component.text()).toMatch("https://github.com/artsy/force")
  })

  it("renders block if provided", () => {
    expect(component.find(Button).first().text()).toMatch("Blocked")
    expect(component.text()).toMatch(
      "Something happened and we can't deploy the project.",
    )
  })

  it("renders maintenance messages if provided", () => {
    expect(component.text()).toMatch("Maintenance recomended")
    expect(component.text()).toMatch(
      "Enable Renovate to receive automatic PRs when orb versions change.",
    )
  })

  it("renders stages", () => {
    expect(component.find(StackableBorderBox).at(0).text()).toMatch("master")
    expect(component.find(StackableBorderBox).at(0).text()).toMatch(
      "Up to date",
    )
    expect(component.find(StackableBorderBox).at(1).text()).toMatch("staging")
    expect(component.find(StackableBorderBox).at(1).text()).toMatch(
      "1 commit behind",
    )
    expect(component.find(StackableBorderBox).at(2).text()).toMatch(
      "production",
    )
    expect(component.find(StackableBorderBox).at(2).text()).toMatch(
      "1 commit behind",
    )
  })

  it("renders criticality", () => {
    expect(component.find(Tags).at(0).text()).toMatch("2: Important")
  })

  it("renders teams", () => {
    expect(component.find(Tags).at(1).text()).toMatch("platform")
  })

  it("renders deployment type if present", () => {
    expect(component.text()).toMatch("Kubernetes")
  })

  it("renders CI provider if present", () => {
    expect(component.text()).toMatch("Circleci")
  })

  it("renders orbs if present", () => {
    expect(component.text()).toMatch("hokusai")
    expect(component.text()).toMatch("yarn")
  })

  it("renders dependencies if present", () => {
    expect(component.text()).toMatch("ruby 2.6.5")
    expect(component.text()).toMatch("node ^10.15.1")
  })

  it("renders if renovate is enabled", () => {
    expect(component.text()).toMatch("Renovate")
  })
})
