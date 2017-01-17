require "jobber/configurable"
require "jobber/version"
require "jobber/client"
require "active_support/all"

module Jobber
  extend Jobber::Configurable

  class AccessTokenRefreshError < StandardError; end
  class AuthorizationError < StandardError; end
  class ApiServerError < StandardError; end
end
