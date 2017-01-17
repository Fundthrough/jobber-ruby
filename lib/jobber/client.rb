require "jwt"
require "jobber/api/base"
require "jobber/api/token"
require "jobber/api/account"
require "jobber/api/client"
require "jobber/api/invoice"
require "jobber/api/transaction"

module Jobber
  class Client
    attr_reader :refresh_token

    def initialize(refresh_token:)
      @refresh_token = refresh_token
    end

    def refresh_access_token!
      response = token.refresh
      @access_token = response.body.access_token
      @token_expired_at = Time.at(JWT.decode(@access_token, nil, false)[0]["exp"])
    end

    def access_token
      refresh_access_token! if token_expired?
      @access_token
    end

    def token
      Jobber::API::Token.new(self)
    end

    def account
      Jobber::API::Account.new(self)
    end

    def client
      Jobber::API::Client.new(self)
    end

    def invoice
      Jobber::API::Invoice.new(self)
    end

    def transaction
      Jobber::API::Transaction.new(self)
    end

    protected

    def token_expired?
      !(@token_expired_at.present? && @token_expired_at.future?)
    end

  end
end
