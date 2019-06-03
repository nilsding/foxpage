# frozen_string_literal: true

module FoxPage
  module AppParts
    module Builder
      extend Base

      def build
        SiteBuilder.build(self)
      end
    end
  end
end
