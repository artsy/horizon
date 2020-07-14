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
    expect(unreleasedProject.find(XCircleIcon).prop("fill")).toEqual(
      "yellow100",
    )
  })

  it("shows project criticality", () => {
    const releasedProject = component
      .find(ProjectsListRow)
      .first()
      .find("[data-test='criticality']")
      .first()
    const unreleasedProject = component
      .find(ProjectsListRow)
      .last()
      .find("[data-test='criticality']")
      .first()
    expect(releasedProject.text()).toMatch("3: Critical")
    expect(unreleasedProject.text()).toMatch("2: Important")
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

  describe("dependencies", () => {
    it("shows dependencies are up to date", () => {
      props.projects[0].dependencies = [
        {
          name: "ruby",
          updateRequired: false,
          version: "2.6.6",
        },
      ]
      component = getWrapper(props)
      const project = component
        .find(ProjectsListRow)
        .first()
        .find("[data-test='dependencies']")
      expect(project.find(CircleBlackCheckIcon).length).toBe(1)
    })

    it("shows dependencies are out of date", () => {
      props.projects[0].dependenciesUpToDate = false
      props.projects[0].dependencies = [
        {
          name: "ruby",
          updateRequired: null,
          version: "unknown version",
        },
      ]
      component = getWrapper(props)
      const project = component
        .find(ProjectsListRow)
        .first()
        .find("[data-test='dependencies']")
      expect(project.find(XCircleIcon).length).toBe(1)
      expect(project.find(XCircleIcon).prop("fill")).toBe("yellow100")
    })

    it("shows dependencies lack version declarations", () => {
      props.projects[0].dependenciesUpToDate = false
      props.projects[0].dependencies = [
        {
          name: "ruby",
          updateRequired: true,
          version: "2.4.5",
        },
      ]
      component = getWrapper(props)
      const project = component
        .find(ProjectsListRow)
        .first()
        .find("[data-test='dependencies']")
      expect(project.find(XCircleIcon).length).toBe(1)
      expect(project.find(XCircleIcon).prop("fill")).toBe("red100")
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
