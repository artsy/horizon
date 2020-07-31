# frozen_string_literal: true

Horizon.mattr_accessor :config

Horizon.config = {
  basic_auth_user: ENV['BASIC_AUTH_USER'] || 'admin',
  basic_auth_pass: ENV['BASIC_AUTH_PASS'],
  minimum_version_ruby: ENV['MINIMUM_VERSION_RUBY'],
  minimum_version_node: ENV['MINIMUM_VERSION_NODE']
}

if Rails.env.production? # require certain config before booting in production
  raise 'BASIC_AUTH_PASS is required' if Horizon.config.basic_auth_pass.blank?
end
