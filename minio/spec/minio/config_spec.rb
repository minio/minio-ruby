# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe MinioRuby::Config do
  context 'without params' do
    it { expect(subject.endpoint).to eq('http://localhost:9000') }
    it { expect(subject.access_key).to be_nil }
    it { expect(subject.secret_key).to be_nil }
    it { expect(subject.secure).to be_nil }
    it { expect(subject.transport).to be_nil }
    it { expect(subject.region).to eq('us-east-1') }
  end

  context 'with params' do
    let(:options) do
      {
        endpoint: 'http://1.2.3.4:4000',
        access_key: 'key',
        secret_key: 'secret',
        secure: true,
        transport: 'https',
        region: 'us-west-1'
      }
    end

    subject(:subject) { described_class.new(options) }

    it { expect(subject.endpoint).to eq(options[:endpoint]) }
    it { expect(subject.access_key).to eq(options[:access_key]) }
    it { expect(subject.secret_key).to eq(options[:secret_key]) }
    it { expect(subject.secure).to eq(options[:secure]) }
    it { expect(subject.transport).to eq(options[:transport]) }
    it { expect(subject.region).to eq(options[:region]) }
  end

  describe '#endpoint' do
    let(:options) { {} }
    subject(:subject) { described_class.new(options) }

    context 'URI without schema' do
      let(:options) do
        { endpoint: '1.2.3.4:4000' }
      end

      it { expect(subject.endpoint).to eq("http://#{options[:endpoint]}") }
    end

    context 'setting a URI without schema' do
      it 'adds http://' do
        subject.endpoint = 'example.com'
        expect(subject.endpoint).to eq('http://example.com')
      end
    end

    context 'URI with schema' do
      it 'has http://' do
        subject.endpoint = 'http://example.com'
        expect(subject.endpoint).to eq('http://example.com')
      end

      it 'has https://' do
        subject.endpoint = 'https://example.com'
        expect(subject.endpoint).to eq('https://example.com')
      end
    end
  end
end
