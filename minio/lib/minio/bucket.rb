# frozen_string_literal: true

module MinioRuby
  class Bucket
    attr_reader :name, :created_at

    class << self
      def bulk_init_from_xml(xml)
        Nokogiri::XML(xml)
                .document.xpath('//xmlns:Bucket')
                .map { |node| init_from_xml(node) }
      end

      def init_from_xml(node)
        name = node.at_css('Name').text
        created_at = node.at_css('CreationDate').text

        new(name: name, created_at: Time.parse(created_at))
      end
    end

    def initialize(name:, created_at: nil)
      @name = name
      @created_at = created_at
    end
  end
end
