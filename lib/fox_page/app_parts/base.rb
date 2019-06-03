# frozen_string_literal: true

module FoxPage
  module AppParts
    module Base
      def priority(priority)
        AppParts[self][:priority] ||= priority
      end

      def init(&block)
        AppParts[self][:block] ||= block
      end
    end
  end
end
