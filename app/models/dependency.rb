# frozen_string_literal: true

require "semantic"
require "semantic/core_ext"

class Dependency < ApplicationRecord
  belongs_to :project

  def as_json
    {
      id: id,
      name: name,
      version: version,
      updateRequired: update_required?
    }
  end

  def update_required?
    required_version = Horizon.config.stringify_keys["minimum_version_#{name}"]
    expectation = Semantic::Version.new(required_version) if required_version
    return unless expectation && version

    if version.is_version?
      current = version.to_version
      current < expectation
    else
      # FIXME: backup to handle non-semantic version syntax coming from projects
      current = version.delete("^0-9.").split(".")
      current_major = current[0]&.to_i
      current_minor = current[1]&.to_i
      return unless current_major

      return true if current_major < expectation.major
      return true if current_minor && current_minor < expectation.minor

      false
    end
  end
end
