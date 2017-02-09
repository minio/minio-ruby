# coding: utf-8
version = File.read(File.expand_path('../../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "minio"
  spec.version       = version
  spec.authors       = ["Minio, Inc."]
  spec.email         = ["dev@minio.io"]

  spec.summary       = %q{Minio Client SDK for Ruby}
  spec.description   = %q{The official Minio Client SDK for Ruby.}
  spec.homepage      = "https://github.com/minio/minio-ruby"
  spec.license       = 'Apache-2.0'

  spec.require_paths = ["lib"]

  spec.files  = Dir['lib/**/*.rb']
  spec.bindir = 'bin'

  spec.add_dependency('http', '~> 2.0')
end
