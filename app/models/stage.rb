# frozen_string_literal: true

class Stage < ApplicationRecord
  belongs_to :project
  belongs_to :profile, optional: true
  has_many :ahead_comparisons, class_name: "Comparison", foreign_key: :ahead_stage, dependent: :destroy
  has_many :behind_comparisons, class_name: "Comparison", foreign_key: :behind_stage, dependent: :destroy
  has_many :deploy_strategies, dependent: :destroy

  acts_as_list scope: :project

  scope :ordered, -> { order("position ASC") }
end
