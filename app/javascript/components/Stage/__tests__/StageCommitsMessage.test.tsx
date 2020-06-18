import {
  comparedStageUpToDate,
  comparedStageWithDiff,
} from "../../../fixtures/comparedStage"
import { CommitsMessage } from "../StageCommitsMessage"
import React from "react"
import { mount } from "enzyme"

describe("StageCommitsMessage", () => {
  it("Returns expected text with no commits", () => {
    const component = mount(<CommitsMessage {...comparedStageUpToDate} />)
    expect(component.text()).toBe("Up to date")
  })

  it("Returns expected text with one commit", () => {
    const component = mount(<CommitsMessage {...comparedStageWithDiff} />)
    expect(component.text()).toBe("1 commit behind")
  })

  it("Returns expected text with many commits", () => {
    const stage = { ...comparedStageWithDiff }
    stage.snapshot.description.push("another commit")
    const component = mount(<CommitsMessage {...stage} />)
    expect(component.text()).toBe("2 commits behind")
  })
})
