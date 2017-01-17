module Jobber
  module API
    class Client < Base
      def list(query = {})
        endpoint = "/clients"
        query = { query: query } if query.present?

        request(:get, endpoint, query)
      end
    end
  end
end
