class ApplicationController < ActionController::Base
  http_basic_authenticate_with(
    name: Horizon.config[:basic_auth_user],
    password: Horizon.config[:basic_auth_pass]
  ) if Horizon.config[:basic_auth_pass].present?
end
