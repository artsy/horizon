# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def admin_basic_auth
    return if Horizon.config[:basic_auth_pass].blank?

    http_basic_authenticate_or_request_with(
      name: Horizon.config[:basic_auth_user],
      password: Horizon.config[:basic_auth_pass]
    )
  end

  def set_admin_timezone
    Time.zone = 'Eastern Time (US & Canada)'
  end
end
