module Jobber
  module API
    class Token < Base
      def refresh
        endpoint = "/oauth/token"
        query = {
          client_id:      Jobber.configs.client_id,
          client_secret:  Jobber.configs.client_secret,
          refresh_token:  jobber_client.refresh_token,
          grant_type:     "refresh_token"
        }

        request(:post, endpoint, query: query)

      rescue Jobber::AuthorizationError => e
        raise Jobber::AccessTokenRefreshError, e
      end

      def revoke
        endpoint = "/oauth/revoke"
        query = { refresh_token: jobber_client.refresh_token }

        request(:get, endpoint, query: query)
      end

      protected

      # Overrides request method in base class to avoid:
      # 1. Adding authorization header
      # 2. Rescuing the request in case any errors
      def request(*args)
        ::Jobber::Fetcher.request(*args)
      end
    end
  end
end
