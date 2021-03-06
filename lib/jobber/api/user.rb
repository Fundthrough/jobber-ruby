module Jobber
  module API
    class User < Base
      def get(user_id)
        endpoint = "/users/#{user_id}"

        request(:get, endpoint)
      end

      def current
        endpoint = "/users/me"

        request(:get, endpoint)
      end
    end
  end
end
