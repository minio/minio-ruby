# frozen_string_literal: true

module MinioRuby
  class InvalidEndpointError < StandardError
    attr_reader :str
    def initialize(msg = 'Invalid Endpoint Error', str)
      @str = str
      super
    end
  end
end
