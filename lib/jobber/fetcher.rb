require "httparty"

module Jobber
  class Fetcher
    include HTTParty
    base_uri "https://api.getjobber.com/api"
    headers "Content-Type" => "application/json"
    debug_output $stdout if Jobber.configs.verbose

    class << self
      def request(method, endpoint, opts = {})
        tries = 0
        loop do
          begin
            break fetch(method, endpoint, opts)
          rescue Net::ReadTimeout, Errno::ECONNREFUSED, Net::OpenTimeout => e
            raise e if (tries += 1) > Jobber.configs.max_retries.to_i
          end
        end
      end

      protected

      def fetch(method, endpoint, opts)
        response = send(method, endpoint, opts)

        handle_errors(response)

        Hashie::Mash.new(
          success?:    response.success?,
          status_code: response.code,
          body:        parse_json(response.body),
          headers:     response.headers
        )
      end

      def handle_errors(response)
        case response.code
        when 500
          raise Jobber::ApiServerError, response.body
        when 401
          raise Jobber::AuthorizationError, response.body
        end
        # TODO: Handle other errors
      end

      def parse_json(body)
        result = JSON.parse(body.to_s)
        Hashie::Mash.new(result)
      rescue JSON::ParserError
        body
      end
    end
  end
end
