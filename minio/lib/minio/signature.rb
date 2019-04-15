# frozen_string_literal: true

module MinioRuby
  class Signature
    attr_reader :headers, :options

    def initialize(headers: {}, **options)
      @headers = headers.to_h
      @options = options
    end

    def content_sha256
      headers['x-amz-content-sha256']
    end

    def authorization
      headers['authorization']
    end
  end
end
