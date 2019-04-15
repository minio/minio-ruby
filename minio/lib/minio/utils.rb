# frozen_string_literal: true

module MinioRuby
  module Utils
    module_function

    def uri_escape_path(path)
      path.gsub(%r{[^/]+}) do |part|
        uri_escape(part)
      end
    end

    def uri_escape(string)
      return unless string

      CGI
        .escape(string.encode('UTF-8'))
        .gsub('+', '%20')
        .gsub('%7E', '~')
    end

    def host(uri)
      if standard_port?(uri)
        uri.host
      else
        "#{uri.host}:#{uri.port}"
      end
    end

    def standard_port?(uri)
      (uri.scheme == 'http' && uri.port == 80) ||
        (uri.scheme == 'https' && uri.port == 443)
    end
  end
end
