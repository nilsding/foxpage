# frozen_string_literal: true

module FoxPage
  class Controller
    DEFAULT_LAYOUT = "layouts/default.haml"
    private_constant :DEFAULT_LAYOUT

    def self.layout
      DEFAULT_LAYOUT
    end

    def self.before_action(method_name)
      @__before_actions ||= []
      @__before_actions << method_name
    end
  end
end
