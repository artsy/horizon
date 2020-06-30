import {
  releasedProjectFixture,
  unreleasedProjectFixture,
} from "../../../fixtures/project"
import { ProjectsList, ProjectsListRow } from "../ProjectsList"
import { CircleBlackCheckIcon, Theme, XCircleIcon } from "@artsy/palette"
import React from "react"
import { mount } from "enzyme"

describe("ProjectsList", () => {
  let props
  let component
  const getWrapper = (passedProps = props) => {
    return mount(
      <Theme>
        <ProjectsList {...passedProps} />
      </Theme>,
    )
  }

  beforeEach(() => {
    props = {
      projects: [releasedProjectFixture, unreleasedProjectFixture],
    }
    component = getWrapper()
  })

  it("shows all projects", () => {
    expect(component.text()).toMatch(releasedProjectFixture.name)
    expect(component.text()).toMatch(unreleasedProjectFixture.name)
  })

  it("shows release severity", () => {
    const releasedProject = component
      .find(ProjectsListRow)
      .first()
      .find("[data-test='severity']")
    const unreleasedProject = component
      .find(ProjectsListRow)
      .last()
      .find("[data-test='severity']")
    expect(releasedProject.find(CircleBlackCheckIcon).length).toBe(1)
    expect(unreleasedProject.find(XCircleIcon).length).toBe(1)
    expect(unreleasedProject.find(XCircleIcon).props().fill).toBe("yellow100")
  })

  describe("auto deploy prs", () => {
    it("shows auto deploys are enabled", () => {
      const project = component
        .find(ProjectsListRow)
        .first()
        .find("[data-test='isAutoDeploy']")
      expect(project.find(CircleBlackCheckIcon).length).toBe(1)
    })

    it("shows when auto deploys are missing if app deployed with kubernetes", () => {
      const project = component
        .find(ProjectsListRow)
        .last()
        .find("[data-test='isAutoDeploy']")
      expect(project.find(XCircleIcon).length).toBe(1)
    })
  })

  describe("renovate", () => {
    it("shows renovate is enabled", () => {
      const project = component
        .find(ProjectsListRow)
        .first()
        .find("[data-test='renovate']")
      expect(project.find(CircleBlackCheckIcon).length).toBe(1)
    })
    it("shows renovate is missing if orbs present", () => {
      props.projects[0].renovate = false
      component = getWrapper(props)
      const project = component
        .find(ProjectsListRow)
        .first()
        .find("[data-test='renovate']")
      expect(project.find(XCircleIcon).length).toBe(1)
    })
    it("shows renovate is missing if kubernetes", () => {
      delete props.projects[0].orbs
      props.projects[0].renovate = false
      component = getWrapper(props)
      const project = component
        .find(ProjectsListRow)
        .first()
        .find("[data-test='renovate']")
      expect(project.find(XCircleIcon).length).toBe(1)
    })
    it("shows n/a if no orbs and not kubernetes", () => {
      delete props.projects[0].orbs
      props.projects[0].renovate = false
      props.projects[0].isKubernetes = false
      component = getWrapper(props)
      const project = component
        .find(ProjectsListRow)
        .last()
        .find("[data-test='renovate']")
      expect(project.find(XCircleIcon).length).toBe(0)
    })
  })
})
