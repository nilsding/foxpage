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

    # Instructs the site builder to generate pages for all records of `model`.
    def self.generate_all(model)
      @__generate_all = model
    end

    def self.method_added(method_name)
      return unless @__generate_all

      @__generate_all_for ||= {}
      @__generate_all_for[method_name] = @__generate_all
      @__generate_all = nil
    end
  end
end
