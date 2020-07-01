# frozen_string_literal: true

Horizon.mattr_accessor :config

Horizon.config = {
  basic_auth_user: ENV['BASIC_AUTH_USER'] || 'admin',
  expected_version_ruby: ENV['EXPECTED_VERSION_RUBY'],
  expected_version_node: ENV['EXPECTED_VERSION_NODE']
}
