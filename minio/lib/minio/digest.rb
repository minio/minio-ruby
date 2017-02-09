# encoding: UTF-8
require "openssl"

module MinioRuby
   
   class Digestor
	 	# calculate sha256 hex digest.
		def self.hexdigest(value)
		  Digest::SHA256.new.update(value).hexdigest
		end

		# calculate hmac digest.
		def self.hmac(key, value)
		  OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, value)
		end

		# calculate hmac hex digest.
		def self.hexhmac(key, value)
		  OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, value)
		end
        
        def self.base64(value)
            return Digest::MD5.base64digest(value)
        end
	end	


 end