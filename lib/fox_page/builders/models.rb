# frozen_string_literal: true

module FoxPage
  module Builders
    module Models
      def load_models
        inject_app_to_models
      end

      private

      def inject_app_to_models
        return if already_injected?

        FoxPage::Model.instance_variable_set(:@__app, app)
      end

      def already_injected?
        FoxPage::Model.instance_variable_get(:@__app)
      end
    end
  end
end
