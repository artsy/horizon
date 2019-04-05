# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_05_023407) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comparisons", force: :cascade do |t|
    t.bigint "snapshot_id"
    t.bigint "ahead_stage_id"
    t.bigint "behind_stage_id"
    t.boolean "released"
    t.text "description", default: [], array: true
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ahead_stage_id"], name: "index_comparisons_on_ahead_stage_id"
    t.index ["behind_stage_id"], name: "index_comparisons_on_behind_stage_id"
    t.index ["snapshot_id"], name: "index_comparisons_on_snapshot_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.string "basic_username"
    t.string "basic_password"
    t.jsonb "environment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_profiles_on_organization_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "snapshot_id"
    t.string "description"
    t.index ["organization_id"], name: "index_projects_on_organization_id"
    t.index ["snapshot_id"], name: "index_projects_on_snapshot_id"
  end

  create_table "snapshots", force: :cascade do |t|
    t.bigint "project_id"
    t.datetime "refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_message"
    t.index ["project_id"], name: "index_snapshots_on_project_id"
  end

  create_table "stages", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.bigint "project_id"
    t.string "git_remote"
    t.string "tag_pattern"
    t.string "branch"
    t.string "hokusai"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_id"
    t.index ["profile_id"], name: "index_stages_on_profile_id"
    t.index ["project_id"], name: "index_stages_on_project_id"
  end

  add_foreign_key "comparisons", "snapshots"
  add_foreign_key "comparisons", "stages", column: "ahead_stage_id"
  add_foreign_key "comparisons", "stages", column: "behind_stage_id"
  add_foreign_key "profiles", "organizations"
  add_foreign_key "projects", "organizations"
  add_foreign_key "projects", "snapshots"
  add_foreign_key "snapshots", "projects"
  add_foreign_key "stages", "profiles"
  add_foreign_key "stages", "projects"
end
