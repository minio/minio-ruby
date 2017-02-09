
require "openssl"
require "time"
require "uri"
require "pathname"
require "minio/digest"

module MinioRuby
	class Signer
	    RFC8601BASIC = "%Y%m%dT%H%M%SZ"
	    SIGNV4ALGO = 'AWS4-HMAC-SHA256'
	    attr_reader :access_key, :secret_key, :region, :date, :service
	    attr_reader :method, :uri, :headers

	    # Initialize signer for calculating your signature.
	    # Params:
	    # +config+: configuration data with access keys and region.
	    def initialize(config)
	      @access_key = config[:access_key] || config["access_key"]
	      @secret_key = config[:secret_key] || config["secret_key"]
	      @region = config[:region] || config["region"]
	      @date = Time.now.utc.strftime(RFC8601BASIC)
	      @service = "s3"      
	    end

	    # Signature v4 function returns back headers with Authorization header.
	    # Params:
	    # +method+: http method.
	    # +endpoint+: S3 endpoint URL.
	    def sign_v4(method, endpoint, headers, body = nil, debug = false)
	      @method = method.upcase
	      @endpoint = endpoint
	      @headers = headers
	      @uri = URI(endpoint)
          
          puts "EP : "+@endpoint
          puts "Headers : "+@headers.to_s
          
	      headers["X-Amz-Date"] = date
          headers["X-Amz-Content-Sha256"] = Digestor.hexdigest(body || "")
         
          
	      headers["Host"] = get_host(@uri)
          puts "--->" + get_host(@uri)
           
          
	      dump if debug
	      signed_headers = headers.dup

	      signed_headers['Authorization'] = get_authorization(headers)
	      signed_headers
	    end

	    private

	    # Get host header value from endpoint.
	    # Params:
	    # +endpoint+: endpoint URI object.
	    def get_host(endpoint)
          puts "recieved : "+ endpoint.to_s
          puts "port : "+ endpoint.port.to_s    
	      if endpoint.port  
            if ((endpoint.port == 443) || (endpoint.port == 80)) 
	             return endpoint.host 
            else
                return endpoint.host + ":" + endpoint.port.to_s 
            end    
	      else
	        #return endpoint.host
            return endpoint.host + ":" + endpoint.port.to_s 
	      end
	    end
        
	     
        
        

	    # Get authorization header value.
	    # Params:
	    # +headers+: list of headers supplied for the request.
	    def get_authorization(headers)
	      [
	        "AWS4-HMAC-SHA256 Credential=#{access_key}/#{credential_scope}",
	        "SignedHeaders=#{headers.keys.map(&:downcase).sort.join(";")}",
	        "Signature=#{signature}"
	      ].join(', ')
	    end

	    # Calculate HMAC based signature in following format.
	    # --- format ---
	    # kSecret = Your AWS Secret Access Key 
	    # kDate = HMAC("AWS4" + kSecret, Date)
	    # kRegion = HMAC(kDate, Region)
	    # kService = HMAC(kRegion, Service)
	    # kSigning = HMAC(kService, "aws4_request")
	    # --------------
	    def signature
	      k_date = Digestor.hmac("AWS4" + secret_key, date[0,8])
	      k_region = Digestor.hmac(k_date, region)
	      k_service = Digestor.hmac(k_region, service)
	      k_credentials = Digestor.hmac(k_service, "aws4_request")
	      Digestor.hexhmac(k_credentials, string_to_sign)
	    end

	    # Generate string to sign.
	    # --- format ---
	    # StringToSign  =
	    #  Algorithm + '\n' +
	    #  RequestDate + '\n' +
	    #  CredentialScope + '\n' +
	    #  HashedCanonicalRequest
	    # --------------
	    def string_to_sign
	      [
	        SIGNV4ALGO,
	        date,
	        credential_scope,
	        Digestor.hexdigest(canonical_request)
	      ].join("\n")
	    end

	    # Generate credential scope.
	    # --- format ---
	    # <mmddyyyy>/<region>/<service>/aws4_request
	    # --------------
	    def credential_scope
	      [
	        date[0,8],
	        region,
	        service,
	        "aws4_request"
	      ].join("/")
	    end

	    # Generate a canonical request of following style.
	    # --- format ---
	    # canonicalRequest =
	    #  <HTTPMethod>\n
	    #  <CanonicalURI>\n
	    #  <CanonicalQueryString>\n
	    #  <CanonicalHeaders>\n
	    #  <SignedHeaders>\n
	    #  <HashedPayload>
	    # --------------
	    def canonical_request
	      [
	        method,
	        Pathname.new(uri.path).cleanpath.to_s,
	        uri.query,
	        headers.sort.map {|k, v| [k.downcase,v.strip].join(':')}.join("\n") + "\n",
	        headers.sort.map {|k, v| k.downcase}.join(";"),
	        headers["X-Amz-Content-Sha256"]
	      ].join("\n")
	    end

	     def dump
          puts "-----------------DUMP BEGIN ---------------------"     
      	  puts "string to sign"
     	  puts string_to_sign
	      puts "canonical_request"
	      puts canonical_request
	      puts "authorization"
          puts "-----------------DUMP END ----------------------"
    end
	  end

	   

end	