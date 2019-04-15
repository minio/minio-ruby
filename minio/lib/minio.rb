# frozen_string_literal: true

require 'base64'
require 'openssl'
require 'uri'
require 'digest'
require 'rest-client'
require 'time'
require 'pathname'
require 'pry'
require 'set'
require 'cgi'
require 'nokogiri'

require 'minio/config'
require 'minio/utils'
require 'minio/signature'
require 'minio/signer'
require 'minio/digestor'
require 'minio/bucket'
require 'minio/client'

module MinioRuby
  class Error < StandardError; end
  class MissingHttpMethodError < Error; end
  class MissingUrlError < Error; end
  class InvalidBucketName < Error; end
end
