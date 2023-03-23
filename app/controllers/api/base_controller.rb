# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    before_action :admin_basic_auth
  end
end
