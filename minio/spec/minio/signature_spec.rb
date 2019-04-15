# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MinioRuby::Signature do
  subject(:subject) { described_class.new(headers: headers) }
  let(:headers) do
    {
      'x-amz-content-sha256' => 'a',
      'authorization' => 'b'
    }
  end

  it { expect(subject.headers).to match(headers) }
  it { expect(subject.options).to match({}) }
  it { expect(subject.content_sha256).to eq('a') }
  it { expect(subject.authorization).to eq('b') }
end
