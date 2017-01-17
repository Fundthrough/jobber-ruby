module Jobber
  autoload :Fetcher, "jobber/fetcher"
  module API
    class Base
      attr_reader :jobber_client

      def initialize(jobber_client)
        @jobber_client = jobber_client
      end

      protected

      def request(*args)
        args[2] = args[2].to_h.deep_merge!(headers: { "Authorization" => "Bearer #{jobber_client.access_token}" })
        ::Jobber::Fetcher.request(*args)
      rescue Jobber::AuthorizationError
        jobber_client.refresh_access_token!
        request(*args)
      end
    end
  end
end
