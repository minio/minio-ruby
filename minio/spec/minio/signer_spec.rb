require 'spec_helper'

RSpec.describe MinioRuby::Signer do
  before(:all) do
    MinioRuby::Client.configure do |config|
      config.access_key = "akid"
      config.secret_key = "secret"
      config.region = "REGION"
    end
  end

  let(:config) { MinioRuby::Client.configure }

  it 'populates the Host header' do
    signature = described_class.new(config: config).sign_request(
      http_method: 'GET',
      url: 'http://domain.com'
    )
    expect(signature.headers['host']).to eq('domain.com')
  end

  it 'includes HTTP port in Host when not 80' do
    signature = described_class.new(config: config).sign_request(
      http_method: 'GET',
      url: 'http://domain.com:123'
    )
    expect(signature.headers['host']).to eq('domain.com:123')
  end

  it 'includes HTTPS port in Host when not 443' do
    signature = described_class.new(config: config).sign_request(
      http_method: 'GET',
      url: 'https://domain.com:123'
    )
    expect(signature.headers['host']).to eq('domain.com:123')
  end

  it 'sets the X-Amz-Date header' do
    now = Time.now
    allow(Time).to receive(:now).and_return(now)
    signature = described_class.new(config: config).sign_request(
      http_method: 'GET',
      url: 'https://domain.com:123'
    )
    expect(signature.headers['x-amz-date']).to eq(now.utc.strftime("%Y%m%dT%H%M%SZ"))
  end

  it 'uses the X-Amz-Date header of the request if present' do
    now = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    signature = described_class.new(config: config).sign_request(
      http_method: 'GET',
      url: 'https://domain.com',
      headers: {
        'X-Amz-Date' => now
      }
    )
    expect(signature.headers['x-amz-date']).to eq(now)
  end

  it 'adds the X-Amz-Content-Sha256 header by default' do
    signature = described_class.new(config: config).sign_request(
      http_method: 'GET',
      url: 'https://domain.com',
      body: 'abc'
    )
    expect(signature.headers['x-amz-content-sha256']).to eq(Digest::SHA256.hexdigest('abc'))
  end

  it 'can omit the X-Amz-Content-Sha256 header' do
    signature = described_class.new(config: config, apply_checksum_header: false).sign_request(
      http_method: 'GET',
      url: 'https://domain.com',
      body: 'abc'
    )
    expect(signature.headers['x-amz-content-sha256']).to be(nil)
  end

  it 'does not read the body if X-Amz-Content-Sha256 if already present' do
    body = double('http-payload')
    expect(body).to_not receive(:read)
    expect(body).to_not receive(:rewind)
    signature = described_class.new(config: config).sign_request(
      http_method: 'PUT',
      url: 'http://domain.com',
      headers: {
        'X-Amz-Content-Sha256' => 'hexdigest'
      },
      body: body
    )
    expect(signature.headers['x-amz-content-sha256']).to eq('hexdigest')
  end

  it "populates the 'Authorization' header" do
    headers = {}
    signature = described_class.new(config: config).sign_request(
      http_method: 'PUT',
      url: 'http://domain.com',
      headers: headers
    )
    # applied to the signature headers, not the request
    expect(headers['authorization']).to be(nil)
    expect(signature.headers['authorization']).to_not be(nil)
  end

  it 'signs the request' do
    allow(Time).to receive(:now).and_return(Time.parse('20120101T112233Z'))
    expected = "AWS4-HMAC-SHA256 Credential=akid/20120101/REGION/s3/aws4_request, SignedHeaders=bar;bar2;foo;host;x-amz-content-sha256;x-amz-date, Signature=a2c93954a91d32df3cd6bef0401f43b81ffa6d220a5722e0694c81f1af0fcf45"

    signature = described_class.new(config: config, unsigned_headers: ['content-length']).sign_request(
      http_method: 'PUT',
      url: 'https://domain.com/',
      headers: {
        'Foo' => 'foo',
        'Bar' => 'bar  bar',
        'Bar2' => '"bar  bar"',
        'Content-Length' => 9,
        'X-Amz-Date' => '20120101T112233Z',
      },
      body: 'http-body'
    )

    expect(signature.authorization).to eq(expected)
  end
end
