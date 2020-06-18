import { ComparedStage } from "Typings"

export const comparedStageUpToDate: ComparedStage = {
  stages: [
    {
      id: 27,
      name: "master",
      position: 1,
      project_id: 11,
      git_remote: "https://github.com/artsy/force.git",
      tag_pattern: null,
      branch: null,
      hokusai: null,
      created_at: "2018-11-14T17:26:37.090-05:00",
      updated_at: "2018-11-14T23:24:42.723-05:00",
      profile_id: 1,
    },
    {
      id: 28,
      name: "staging",
      position: 2,
      project_id: 11,
      git_remote: "https://github.com/artsy/force.git",
      tag_pattern: null,
      branch: null,
      hokusai: "staging",
      created_at: "2018-11-14T17:26:37.096-05:00",
      updated_at: "2018-11-14T23:24:42.728-05:00",
      profile_id: 1,
    },
  ],
  snapshot: {
    id: 34970,
    snapshot_id: 19463,
    ahead_stage_id: 27,
    behind_stage_id: 28,
    released: true,
    description: [],
    position: 1,
    created_at: "2020-06-17T05:02:36.335-04:00",
    updated_at: "2020-06-17T05:02:36.335-04:00",
  },
  diff: [],
  blame: "",
  score: 0,
}

export const comparedStageWithDiff: ComparedStage = {
  stages: [
    {
      id: 28,
      name: "staging",
      position: 2,
      project_id: 11,
      git_remote: "https://github.com/artsy/force.git",
      tag_pattern: null,
      branch: null,
      hokusai: "staging",
      created_at: "2018-11-14T17:26:37.096-05:00",
      updated_at: "2018-11-14T23:24:42.728-05:00",
      profile_id: 1,
    },
    {
      id: 29,
      name: "production",
      position: 3,
      project_id: 11,
      git_remote: "https://github.com/artsy/force.git",
      tag_pattern: null,
      branch: null,
      hokusai: "production",
      created_at: "2018-11-14T17:26:37.102-05:00",
      updated_at: "2018-11-14T23:24:42.734-05:00",
      profile_id: 1,
    },
  ],
  snapshot: {
    id: 34971,
    snapshot_id: 19463,
    ahead_stage_id: 28,
    behind_stage_id: 29,
    released: false,
    description: [
      "5536a9026 2020-06-16 Possibly fix the loading issue on the auction registration form (Yuki Nishijima, yk.nishijima@gmail.com)",
    ],
    position: 2,
    created_at: "2020-06-17T05:02:36.341-04:00",
    updated_at: "2020-06-17T05:02:36.341-04:00",
  },
  diff: [
    {
      sha: "5536a9026",
      date: "2020-06-16",
      firstName: "Yuki",
      gravatar:
        "https://www.gravatar.com/avatar/6c7e6a8c3623300cf8992df120e6c2c1",
      href: "https://github.com/artsy/force/commit/5536a9026",
      message:
        "Possibly fix the loading issue on the auction registration form",
    },
  ],
  blame: "Yuki",
  score: 4.4608556519978855,
}
