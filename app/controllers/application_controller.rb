class ApplicationController < ActionController::Base
  http_basic_authenticate_with(
    name: Horizon.config[:basic_auth_user],
    password: Horizon.config[:basic_auth_pass]
  ) if !Rails.env.test? && Horizon.config[:basic_auth_pass].present?

  private

  def set_admin_timezone
    Time.zone = 'Eastern Time (US & Canada)'
  end
end
