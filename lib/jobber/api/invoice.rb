module Jobber
  module API
    class Invoice < Base
      def list(query = {})
        endpoint = "/invoices"
        query = { query: query } if query.present?

        request(:get, endpoint, query)
      end
    end
  end
end
