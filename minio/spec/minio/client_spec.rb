require 'spec_helper'

RSpec.describe MinioRuby::Client do
  before(:all) do
    described_class.config do |config|
      config.access_key = ENV.fetch('MINIO_ACCESS_KEY')
      config.secret_key = ENV.fetch('MINIO_SECRET_KEY')
      config.endpoint = ENV.fetch('MINIO_HOST')
      config.region = 'us-east-1'
    end
  end

  subject(:client) { described_class.new }

  context 'bucket' do
    it 'creates a bucket' do
      expect(client.make_bucket("chunky-bacon-#{Time.now.to_i}")).to be_truthy
    end

    it 'raises error if bucket name contains a /' do
      expect { client.make_bucket("chunky-bacon/#{Time.now.to_i}") }.to(
        raise_error(MinioRuby::InvalidBucketName)
      )
    end

    it 'checks if a bucket exists' do
      expect(client.bucket_exists?(SecureRandom.uuid)).to be_falsy
    end

    it 'checks if a bucket exists' do
      name = SecureRandom.uuid
      client.make_bucket(name)

      expect(client.bucket_exists?(name)).to be_truthy
    end

    it 'lists buckets as an array' do
      expect(client.list_buckets).to all be_a(MinioRuby::Bucket)
    end

    it 'lists buckets as an array' do
      name = SecureRandom.uuid
      client.make_bucket(name)

      expect(client.list_buckets).to all be_a(MinioRuby::Bucket)
    end

    it 'lists buckets as an array' do
      expect(client.list_buckets).to all be_a(MinioRuby::Bucket)
    end

    it 'deletes an existing bucket' do
      name = SecureRandom.uuid
      client.make_bucket(name)

      expect(client.remove_bucket(name)).to be_truthy
    end

    it 'deletes a non-existing bucket' do
      name = SecureRandom.uuid

      expect(client.remove_bucket(name)).to be_falsy
    end

    it 'uploads an object' do
      bucket = SecureRandom.uuid
      client.make_bucket(bucket)
      file = "#{SecureRandom.uuid}.txt"
      content = SecureRandom.alphanumeric(1000)

      expect(client.put_object(bucket, file, content)).to be_truthy
    end

    it 'uploads an object in a directory' do
      bucket = SecureRandom.uuid
      client.make_bucket(bucket)
      file = "#{SecureRandom.uuid}/#{SecureRandom.uuid}.txt"
      content = SecureRandom.alphanumeric(1000)

      expect(client.put_object(bucket, file, content)).to be_truthy
    end

    it 'downloads an object' do
      bucket = SecureRandom.uuid
      client.make_bucket(bucket)
      file = "#{SecureRandom.uuid}.txt"
      content = SecureRandom.alphanumeric(1000)
      client.put_object(bucket, file, content)

      expect(client.get_object(bucket, file)).to eq(content)
    end
  end
end
