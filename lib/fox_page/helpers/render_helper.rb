# frozen_string_literal: true

module FoxPage
  module Helpers
    module RenderHelper
      def render(view, params = {})
        full_path = Dir.glob(app.root.join("app/views/#{view}.*")).first

        unless full_path
          raise ArgumentError, "Could not find template for #{view}"
        end

        Tilt.new(full_path).render(self, params)
      end
    end
  end
end
