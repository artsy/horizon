# frozen_string_literal: true

Horizon.mattr_accessor :config

Horizon.config = {
  basic_auth_user: ENV['BASIC_AUTH_USER'] || 'admin',
  basic_auth_pass: ENV['BASIC_AUTH_PASS']
}
