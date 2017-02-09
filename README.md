## Minio Ruby Library for Amazon S3 Compatible Cloud Storage[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Minio/minio?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The Minio Ruby Client SDK provides simple APIs to access any Amazon S3 compatible object storage server.

The Minio Ruby SDK is work in progress. Please do not use it in development or production. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minio'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minio

# Development
To build the minio gem do
```sh
$ gem build minio.gemspec
```

Install the gem with 
```sh
 $ gem install minio
```

### Testing
Tests cases are being written. Testing can be done with irb.
```sh
$ irb
2.2.2 :001 > require "minio"
 => true 
2.2.2 :002 > quit 
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/minio. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

