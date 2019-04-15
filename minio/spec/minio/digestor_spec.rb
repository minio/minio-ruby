# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MinioRuby::Digestor do
  context 'hexdigest' do
    it 'computes hexdigest for a string' do
      exp = Digest::SHA256.hexdigest('chunky bacon')

      expect(described_class.hexdigest('chunky bacon')).to eq(exp)
    end

    it 'computes hexdigest for a file' do
      file = Tempfile.new('tempfile')
      file.write('abc')
      file.flush
      expected = Digest::SHA256.hexdigest('abc')

      expect(file).not_to receive(:read)
      expect(file).not_to receive(:rewind)
      expect(described_class.hexdigest(file)).to eq(expected)
    end

    it 'computes hexdigest for an IO file' do
      file = StringIO.new('abc')
      expected = Digest::SHA256.hexdigest('abc')

      expect(described_class.hexdigest(file)).to eq(expected)
    end
  end

  it 'computes hmac' do
    data = Base64.encode64(described_class.hmac('chunky', 'bacon'))
    expected = "mscQh8b3Nv+vvZiyDUC2BKNVmca0OnlNeIJZtIV3fnw=\n"

    expect(data).to eql(expected)
  end

  it 'computes hexhmac' do
    exp = '9ac71087c6f736ffafbd98b20d40b604a35599c6b43a794d788259b485777e7c'

    expect(described_class.hexhmac('chunky', 'bacon')).to eq(exp)
  end

  it 'computes base64' do
    expected = 'eS7e9xz127ZFkjEZhdPa7g=='

    expect(described_class.base64('chunky bacon')).to eq(expected)
  end
end
