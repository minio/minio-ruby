# frozen_string_literal: true

module MinioRuby
  class Signer
    extend Forwardable
    def_delegators :@config, :service, :region
    def_delegators :@config, :secret_key, :access_key

    def initialize(config:, **options)
      @config = config
      @options = options
    end

    def sign_request(http_method:, url:, headers: {}, **request)
      http_method = extract_http_method(http_method)
      url = extract_url(url)
      headers = downcase_headers(headers)

      datetime = headers['x-amz-date']
      datetime ||= Time.now.utc.iso8601.gsub(/\W/, '')
      date = datetime[0, 8]

      content_sha256 = headers['x-amz-content-sha256']
      content_sha256 ||= sha256_hexdigest(request[:body] || '')

      sigv4_headers = {}
      sigv4_headers['host'] = Utils.host(url)
      sigv4_headers['x-amz-date'] = datetime
      sigv4_headers['x-amz-content-sha256'] ||= content_sha256 if apply_checksum_header?
      sigv4_headers['content-type'] ||= headers['content-type'] if headers['content-type']

      headers = headers.merge(sigv4_headers)
      signature = compute_signature(http_method: http_method, url: url, headers: headers, content_sha: content_sha256, datetime: datetime)
      sigv4_headers['authorization'] = signature_header(date: date, headers: headers, signature: signature)

      Signature.new(headers: sigv4_headers)
    end

    private

    def extract_http_method(http_method)
      if http_method
        http_method.to_s.upcase
      else
        msg = 'missing required option :http_method'
        raise MissingHttpMethodError, msg
      end
    end

    def extract_url(url)
      if url
        URI.parse(url.to_s)
      else
        msg = 'missing required option :url'
        raise MissingUrlError, msg
      end
    end

    def downcase_headers(headers)
      headers.to_h.each_with_object({}) do |(key, value), acc|
        acc[key.to_s.downcase] = value
      end
    end

    def apply_checksum_header?
      @options[:apply_checksum_header] != false
    end

    def compute_signature(http_method:, url:, headers:, content_sha:, datetime:)
      request = canonical_request(http_method, url, headers, content_sha)
      to_sign = string_to_sign(datetime, request)

      Digestor.signature(
        secret_key: secret_key,
        service: service,
        region: region,
        date: datetime[0, 8],
        string_to_sign: to_sign
      )
    end

    def signature_header(date:, headers:, signature:)
      [
        "AWS4-HMAC-SHA256 Credential=#{credential(access_key, date)}",
        "SignedHeaders=#{signed_headers(headers)}",
        "Signature=#{signature}"
      ].join(', ')
    end

    def canonical_request(http_method, url, headers, content_sha256)
      [
        http_method,
        path(url),
        normalized_querystring(url.query || ''),
        canonical_headers(headers) + "\n",
        signed_headers(headers),
        content_sha256
      ].join("\n")
    end

    def string_to_sign(datetime, canonical_request)
      [
        'AWS4-HMAC-SHA256',
        datetime,
        credential_scope(datetime[0, 8]),
        sha256_hexdigest(canonical_request)
      ].join("\n")
    end

    def credential_scope(date)
      [
        date,
        region,
        service,
        'aws4_request'
      ].join('/')
    end

    def credential(access_key, date)
      "#{access_key}/#{credential_scope(date)}"
    end

    def path(url)
      path = url.path || '/'

      uri_escape_path(path)
    end

    def normalized_querystring(querystring)
      params = querystring.split('&')
      params = params.map { |p| /=/.match?(p) ? p : p + '=' }
      params.each.with_index.sort do |a, b|
        a, a_offset = a
        a_name = a.split('=')[0]
        b, b_offset = b
        b_name = b.split('=')[0]
        if a_name == b_name
          a_offset <=> b_offset
        else
          a_name <=> b_name
        end
      end.map(&:first).join('&')
    end

    def signed_headers(headers)
      headers
        .keys
        .reject { |header| unsigned_headers.include?(header) }
        .sort
        .join(';')
    end

    def canonical_headers(headers)
      headers
        .reject { |header, _value| unsigned_headers.include?(header) }
        .to_a
        .sort_by(&:first)
        .map { |k, v| "#{k}:#{canonical_header_value(v.to_s)}" }
        .join("\n")
    end

    def unsigned_headers
      @unsigned_headers ||= Set
                            .new(@options.fetch(:unsigned_headers, []))
                            .map(&:downcase)
                            .push('authorization')
                            .push('x-amzn-trace-id')
    end

    def canonical_header_value(value)
      /^".*"$/.match?(value) ? value : value.gsub(/\s+/, ' ').strip
    end

    def sha256_hexdigest(value)
      Digestor.hexdigest(value)
    end

    def uri_escape(string)
      Utils.uri_escape(string)
    end

    def uri_escape_path(string)
      Utils.uri_escape_path(string)
    end
  end
end
