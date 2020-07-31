# frozen_string_literal: true

class ApplicationController < ActionController::Base
  if Horizon.config[:basic_auth_pass].present?
    http_basic_authenticate_with(
      name: Horizon.config[:basic_auth_user],
      password: Horizon.config[:basic_auth_pass]
    )
  end

  private

  def set_admin_timezone
    Time.zone = 'Eastern Time (US & Canada)'
  end
end
