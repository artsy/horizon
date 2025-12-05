# frozen_string_literal: true

Horizon.mattr_accessor :config

Horizon.config = {
  basic_auth_user: ENV["BASIC_AUTH_USER"] || "admin",
  basic_auth_pass: ENV.fetch("BASIC_AUTH_PASS", nil),
  minimum_version_ruby: ENV.fetch("MINIMUM_VERSION_RUBY", nil),
  minimum_version_node: ENV.fetch("MINIMUM_VERSION_NODE", nil),
  working_dir: ENV.fetch("WORKING_DIR", nil),
  datadog_service_name: ENV["DATADOG_SERVICE_NAME"] || "horizon",
  datadog_trace_agent_hostname: ENV.fetch("DATADOG_TRACE_AGENT_HOSTNAME", nil),
  sentry_dsn: ENV.fetch("SENTRY_DSN", nil)
}

if Rails.env.production? && Horizon.config[:basic_auth_pass].blank?
  # require certain config before booting in production
  raise "BASIC_AUTH_PASS is required"
end
