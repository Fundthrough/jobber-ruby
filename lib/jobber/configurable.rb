require "hashie"

module Jobber
  module Configurable
    KEYS = [:client_id, :client_secret, :verbose].freeze

    attr_writer(*KEYS)

    def configure
      yield self
      self
    end

    def configs
      @configs ||= begin
        hash = {}
        KEYS.each { |key| hash[key] = instance_variable_get(:"@#{key}") }
        Hashie::Mash.new(hash)
      end
    end
  end
end
