# frozen_string_literal: true

module FoxPage
  module Helpers
    # the AppHelper module builder injects the core FoxPage::Application
    # instance to the method `app`
    class AppHelper < Module
      def initialize(app)
        @__app = app
        define_method(:app) do
          app
        end
      end

      def inspect
        "#{self.class.name}(#{@__app.class})"
      end
    end
  end
end
