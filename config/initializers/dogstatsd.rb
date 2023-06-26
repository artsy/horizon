# frozen_string_literal: true

module Horizon
  def self.dogstatsd
    @dogstatsd ||= Datadog::Statsd.new(
      Horizon.config[:datadog_trace_agent_hostname],
      8125,
      tags: ["service:#{Horizon.config[:datadog_service_name]}"]
    )
  end
end
