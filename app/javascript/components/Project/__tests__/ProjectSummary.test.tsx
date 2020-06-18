import { BorderBox } from "@artsy/palette"
import { ProjectSummary } from "../ProjectSummary"
import React from "react"
import { mount } from "enzyme"
import { unreleasedProjectFixture } from "../../../fixtures/project"

describe("ProjectSummary", () => {
  let props
  const getWrapper = (passedProps = props) => {
    return mount(<ProjectSummary {...passedProps} />)
  }
  beforeEach(() => {
    props = {
      ...unreleasedProjectFixture,
    }
  })
  it("Renders project name and description", () => {
    const component = getWrapper()
    expect(component.text()).toMatch("Force")
    expect(component.text()).toMatch("Artsy.net web front-end")
  })

  it("Renders 'bocked' if blocks", () => {
    const component = getWrapper()
    expect(component.text()).toMatch("Blocked")
  })

  it("Renders up to date stages", () => {
    const component = getWrapper()
    expect(component.text()).toMatch("staging")
    expect(component.text()).toMatch("Up to date")
  })

  it("Renders stages with diff", () => {
    const component = getWrapper()
    expect(component.text()).toMatch("production")
    expect(component.text()).toMatch("1 commit behind")
    expect(component.text()).toMatch("Yuki")
  })

  describe("severity", () => {
    it("Uses default if up to date", () => {
      props.severity = 0
      const component = getWrapper(props)
      expect(component.find(BorderBox).first().props().borderColor).toBe(
        undefined,
      )
    })
    it("Uses yellow border if moderately severe", () => {
      props.severity = 1
      const component = getWrapper(props)
      expect(component.find(BorderBox).first().props().borderColor).toBe(
        "yellow100",
      )
    })
    it("Uses red border if severe", () => {
      props.severity = 10
      const component = getWrapper(props)
      expect(component.find(BorderBox).first().props().borderColor).toBe(
        "red100",
      )
    })

    it("Adds aged class if very severe", () => {
      props.severity = 500
      const component = getWrapper(props)
      expect(component.find(BorderBox).first().props().className).toBe("aged")
    })
  })
})
