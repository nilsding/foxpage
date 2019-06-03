# frozen_string_literal: true

module FoxPage
  module AppParts
    module Routes
      extend Base

      init do
        reload_routes!
      end

      attr_reader :routes

      def draw_routes(&block)
        @routes ||= {}
        @routes.merge!(Router.draw_routes(&block))
      end

      def reload_routes!
        @routes = {}
        load root.join("config", "routes.rb")
      end
    end
  end
end
