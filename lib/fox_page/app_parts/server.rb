# frozen_string_literal: true

module FoxPage
  module AppParts
    module Server
      extend Base

      def server
        @server ||= FoxPage::Server.new(self)
      end
    end
  end
end
