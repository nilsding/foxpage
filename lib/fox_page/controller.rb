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
    # model can be a symbol (which will use an actual FoxPage::Model), or a
    # Proc returning an Enumerable.
    def self.generate_all(model)
      @__generate_all = model
    end

    def self.use_layout(layout)
      @__use_layout = layout
    end

    def self.method_added(method_name)
      return unless @__generate_all.nil? || @__use_layout.nil?

      set_method_option(method_name, "generate_all")
      set_method_option(method_name, "use_layout")
    end

    def self.set_method_option(method_name, option)
      ivar_name = :"@__#{option}"
      ivar_for_name = :"@__#{option}_for"

      ivar_val = instance_variable_get(ivar_name)
      return if ivar_val.nil?

      instance_variable_set(ivar_name, nil)
      unless instance_variable_get(ivar_for_name)
        instance_variable_set(ivar_for_name, {})
      end

      instance_variable_get(ivar_for_name)[method_name] = ivar_val
    end

    private_class_method :set_method_option
  end
end
