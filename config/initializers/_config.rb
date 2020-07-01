# frozen_string_literal: true

Horizon.mattr_accessor :config

Horizon.config = {
  basic_auth_user: ENV['BASIC_AUTH_USER'] || 'admin',
  minimum_version_ruby: ENV['MINIMUM_VERSION_RUBY'],
  minimum_version_node: ENV['MINIMUM_VERSION_NODE']
}
