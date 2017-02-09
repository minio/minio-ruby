require "net/http"
require "net/https"
require "base64"
require "openssl"
require 'uri'
require "minio/signer"
require "minio/digest"
require 'digest'

module MinioRuby
  class MinioClient
    attr_accessor :endPoint, :port, :accessKey, :secretKey, :secure, :transport, :region

    def initialize params = {}
      # TODO: add extensive error checking of params here. 
      params.each { |key, value| send "#{key}=", value }
    end
    
    def getObject(bucketname, objectname)  
      
      req = endPoint + '/' + bucketname + '/' + objectname
      signer = MinioRuby::Signer.new(access_key: self.accessKey, secret_key:self.secretKey, region: self.region)
      body = ""
      headers = {} 
      headers = signer.sign_v4("GET", req, headers, body, true)
      
      uri = URI.parse(self.endPoint)
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true

      req = Net::HTTP::Get.new(self.endPoint + '/' + bucketname + '/' + objectname, initheader = headers)
      req.body = body  
      https.set_debug_output($stdout)
      response = https.request(req)
      
    end

    
    def putObject(bucketname, objectname, data, length, content_type='application/octet-stream')
      req = endPoint + '/' + bucketname + '/' + objectname
      signer = MinioRuby::Signer.new(access_key: self.accessKey, secret_key: self.secretKey , region: self.region)
      headers = {}
      headers = signer.sign_v4("PUT", req, headers, data, true)

      puts data
      uri = URI.parse(self.endPoint)
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true

      req = Net::HTTP::Put.new(self.endPoint + '/'+bucketname+'/'+objectname, initheader = headers)
      req.body = data
      https.set_debug_output($stdout)
      response = https.request(req)

    end

    
    def bucketExists(bucketname)
      

    end

    
    def fputObject(bucketname, objectname, filepath, content_type)



    end
    
    def makeBucket(bucketname, location='us-east-1')
      
      method = "PUT"
      headers = {'User-Agent' => 'MinioRuby'}
      content = ""
      signer = MinioRuby::Signer.new(access_key: self.accessKey, secret_key: self.secretKey , region: self.region)
      body = ""
      
      #headers['Content-Length'] = content.length.to_s
      req = self.endPoint + '/' + bucketname 
      
      
      content_sha256_hex = Digest::SHA256.hexdigest(content)
      #headers['Content-Md5'] = Digest::MD5.base64digest(content)
      
      headers = signer.sign_v4(method, req, headers, body, true)
      
      puts req  
      
      uri = URI.parse(self.endPoint + '/' + bucketname)
      
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true

      req = Net::HTTP::Put.new(uri, initheader = headers)
      req.body = body
      https.set_debug_output($stdout)
      response = https.request(req)
      
      
      if response.code != "200"
        puts "Error Making bucket"
      else
        puts "Made bucket"    
      end
      
    end
    
    
  end

end
