Horizon.mattr_accessor :config

Horizon.config = {
  basic_auth_user: ENV['BASIC_AUTH_USER'] || 'admin',
  basic_auth_pass: ENV['BASIC_AUTH_PASS'],
  default_org_id: ENV['DEFAULT_ORG_ID'],
  github_access_token: ENV['GITHUB_ACCESS_TOKEN']
}
