module Jobber
  module API
    class Transaction < Base
      def list(query = {})
        endpoint = "/transactions"
        query = { query: query } if query.present?

        request(:get, endpoint, query)
      end
    end
  end
end
