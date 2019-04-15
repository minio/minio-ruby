# frozen_string_literal: true

module MinioRuby
  class Config
    attr_accessor :access_key, :secret_key, :region
    attr_accessor :transport, :secure
    attr_reader :service, :endpoint

    def initialize(args = {})
      @endpoint   = ensure_schema(args[:endpoint] || 'localhost:9000')
      @access_key = args[:access_key]
      @secret_key = args[:secret_key]
      @secure     = args[:secure]
      @transport  = args[:transport]
      @region     = args[:region] || 'us-east-1'
      @service    = 's3'
    end

    def endpoint=(uri)
      @endpoint = ensure_schema(uri)
    end

    private

    def ensure_schema(uri)
      return unless uri
      return uri if uri.start_with?('http://', 'https://')

      "http://#{uri}"
    end
  end
end
