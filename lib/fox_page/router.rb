# frozen_string_literal: true

require "ostruct"

module FoxPage
  class Router
    using Refinements::Camelize

    def self.draw_routes(&block)
      new.draw_routes(&block)
    end

    attr_reader :routes

    def initialize
      @routes = {}
    end

    def draw_routes(&block)
      instance_eval(&block)
      routes
    end

    def root(target, params: {})
      routes["/"] = parse_target(target, params: params)
    end

    def map(mapping, params: {})
      mapping.each do |path, target|
        routes[path] = parse_target(target, params: params)
      end
    end

    private

    def parse_target(target, params: {})
      base_name, method_name = target.split("#")
      controller = Kernel.const_get("#{base_name}_controller".camelize)
      method_name = method_name.to_sym

      validate_controller_method(controller, method_name)

      OpenStruct.new(
        base_name: base_name,
        controller: controller,
        method_name: method_name,
        params: OpenStruct.new(params)
      )
    end

    def validate_controller_method(controller, method_name)
      return if controller.instance_methods.include?(method_name)

      raise ArgumentError, "#{controller} does not define ##{method_name}"
    end
  end
end
