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
        response = send(method, endpoint, normalize(method, opts))

        handle_errors(response)

        Hashie::Mash.new(
          success?:    response.success?,
          status_code: response.code,
          body:        parse_json(response.body),
          headers:     response.headers
        )
      end

      def normalize(method, opts)
        return opts unless method == :get

        opts.clone.tap do |o|
          o[:query] = encode(o[:query]) if o[:query].present?
        end
      end

      def encode(query)
        query.map do |k, v|
          if v.is_a? Hash
            v = v.map do |nk, nv|
              op = (nk.to_s == "updated_at" ? ">" : "=")
              "#{nk}#{op}#{nv}"
            end.join(",")
          end
          v = "[#{v}]" if k.to_s == "where"
          v.to_query(k)
        end.join("&")
      end

      def handle_errors(response)
        case response.code
        when 500
          raise Jobber::ApiServerError, response.body
        when 401
          raise Jobber::AuthorizationError, response.body
        end
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
