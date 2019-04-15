# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MinioRuby::Bucket do
  subject(:subject) do
    described_class.new(name: 'chunky-bacon', created_at: Date.today)
  end

  let(:xml_node) do
    <<~NODE
      <Bucket>
        <Name>chunky-bacon</Name>
        <CreationDate>2019-03-03T19:46:18.629Z</CreationDate>
      </Bucket>
    NODE
  end

  it { expect(subject.name).to eq('chunky-bacon') }
  it { expect(subject.created_at).to eq(Date.today) }

  it 'inits from xml' do
    bucket = described_class.init_from_xml(Nokogiri::XML(xml_node))

    expect(bucket.name).to eq('chunky-bacon')
    expect(bucket.created_at).to eq(Time.parse('2019-03-03T19:46:18.629Z'))
  end
end
