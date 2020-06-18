import {
  comparedStageUpToDate,
  comparedStageWithDiff,
} from "../../../fixtures/comparedStage"
import React from "react"
import { StageWithComparison } from "../StageWithComparison"
import { mount } from "enzyme"

describe("StageWithComparison", () => {
  let props
  let component
  const getWrapper = (passedProps = props) => {
    return mount(<StageWithComparison {...passedProps} />)
  }

  describe("up to date", () => {
    beforeEach(() => {
      props = {
        comparison: comparedStageUpToDate,
        stage: comparedStageUpToDate.stages[1],
      }
      component = getWrapper()
    })

    it("Renders the stage name & commits message", () => {
      expect(component.text()).toMatch("staging")
      expect(component.text()).toMatch("Up to date")
    })
  })

  describe("With diff commits", () => {
    beforeEach(() => {
      props = {
        comparison: comparedStageWithDiff,
        stage: comparedStageWithDiff.stages[1],
      }
      component = getWrapper()
    })
    it("Renders the stage name & commits message", () => {
      expect(component.text()).toMatch("production")
      expect(component.text()).toMatch("1 commit behind")
    })

    it("Renders a list of commits", () => {
      expect(component.text()).toMatch("Yuki")
      expect(component.text()).toMatch("2020-06-16")
      expect(component.text()).toMatch(
        "Possibly fix the loading issue on the auction registration form",
      )
      expect(component.html()).toMatch(
        "https://github.com/artsy/force/commit/5536a9026",
      )
    })
  })
})
