# frozen_string_literal: true

module FoxPage
  module Helpers
    module TagHelper
      class TagBuilder
        def initialize(name:, content: nil, options: {})
          @name = name
          @content = content
          @options = options
        end

        def build
          [
            "<",
            [
              @name.to_s,
              *@options.compact.map(&method(:tag_option)),
            ].join(" "),
            ">",
            @content,
            "</",
            @name.to_s,
            ">"
          ].join("")
        end

        private def tag_option(key, value)
          value = value.gsub('"', "&quot;") if value.include? '"'
          [key, %("#{value}")].join("=")
        end
      end

      def content_tag(name, content_or_options_with_block = nil, options = nil, &block)
        content = content_or_options_with_block
        if block_given?
          options = content_or_options_with_block
          content = block.call
        end
        options ||= {}

        TagBuilder.new(name:, content:, options:).build
      end
    end
  end
end
