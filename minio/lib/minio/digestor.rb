# frozen_string_literal: true

module MinioRuby
  class Digestor
    class << self
      def hexdigest(value)
        if value_is_file?(value)
          OpenSSL::Digest::SHA256.file(value).hexdigest
        elsif value.respond_to?(:read)
          fragmented_digest(value)
        else
          OpenSSL::Digest::SHA256.hexdigest(value)
        end
      end

      def hmac(key, value)
        OpenSSL::HMAC.digest(digest, key, value)
      end

      def hexhmac(key, value)
        OpenSSL::HMAC.hexdigest(digest, key, value)
      end

      def base64(value)
        Digest::MD5.base64digest(value)
      end

      def signature(secret_key:, service:, region:, date:, string_to_sign:)
        k_date = hmac('AWS4' + secret_key, date)
        k_region = hmac(k_date, region)
        k_service = hmac(k_region, service)
        k_credentials = hmac(k_service, 'aws4_request')
        hexhmac(k_credentials, string_to_sign)
      end

      private

      def value_is_file?(value)
        (value.is_a?(File) || value.is_a?(Tempfile)) &&
          value.path &&
          File.exist?(value.path)
      end

      def fragmented_digest(value)
        sha256 = OpenSSL::Digest::SHA256.new
        while chunk = value.read(1024 * 1024, buffer ||= ''.dup) # 1MB
          sha256.update(chunk)
        end

        value.rewind
        sha256.hexdigest
      end

      def digest
        OpenSSL::Digest.new('sha256')
      end
    end
  end
end
