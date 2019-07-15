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

    def map(mapping, params: {}, single_file: false)
      mapping.each do |path, target|
        routes[path] = parse_target(target, params: params, single_file: single_file)
      end
    end

    RESOURCE_ACTIONS = %i[index show].freeze

    def resources(name, path: name, only: RESOURCE_ACTIONS)
      actions = only.map(&:to_sym)
      base_name = name.to_s
      controller = controller_for(base_name)
      base_path = "/#{path}"

      # show action needs some additional stuff to make it work
      # since we have to know all the ids beforehand
      if actions.delete :show
        method_name = :show
        validate_controller_method(controller, method_name)
        route_path = "#{base_path}/%<id>s"

        routes[route_path] = make_target(
          base_name: base_name,
          controller: controller,
          method_name: method_name,
          params: {},
          generate_all: controller.instance_variable_get(:@__generate_all_for)&.[](method_name)
        )
      end

      actions.each do |action|
        method_name = action
        validate_controller_method(controller, method_name)
        route_path = method_name == :index ? base_path : "#{base_path}/#{method_name}"

        routes[route_path] = make_target(
          base_name: base_name,
          controller: controller,
          method_name: method_name
        )
      end
    end

    private

    def parse_target(target, params: {}, single_file: false)
      base_name, method_name = target.split("#")
      controller = controller_for(base_name)
      method_name = method_name.to_sym

      validate_controller_method(controller, method_name)

      make_target(
        base_name: base_name,
        controller: controller,
        method_name: method_name,
        params: params,
        single_file: single_file
      )
    end

    def controller_for(base_name)
      Kernel.const_get("#{base_name}_controller".camelize)
    end

    def validate_controller_method(controller, method_name)
      return if controller.instance_methods.include?(method_name)

      raise ArgumentError, "#{controller} does not define ##{method_name}"
    end

    def make_target(base_name:, controller:, method_name:, params: {}, generate_all: nil, single_file: false)
      OpenStruct.new(
        base_name: base_name,
        controller: controller,
        method_name: method_name,
        params: OpenStruct.new(params),
        generate_all: generate_all,
        single_file: single_file
      )
    end
  end
end
