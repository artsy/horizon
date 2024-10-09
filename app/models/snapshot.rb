# frozen_string_literal: true

class Snapshot < ApplicationRecord
  belongs_to :project
  has_many :comparisons, dependent: :destroy
  # nullify useful for cleaning up Project#snapshot references on destroy
  has_one :current_snapshot_for_project, class_name: "Project", dependent: :nullify
end
