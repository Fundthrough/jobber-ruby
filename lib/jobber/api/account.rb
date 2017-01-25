module Jobber
  module API
    class Account < Base
      def get(account_id)
        endpoint = "/accounts/#{account_id}"

        request(:get, endpoint)
      end

      def current
        endpoint = "/accounts/me"

        request(:get, endpoint)
      end
    end
  end
end
