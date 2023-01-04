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

    # compatibility method for old route definition syntax
    #
    # `def map(mapping, params: {}, single_file: false)`
    #
    # see Router#route for the new style
    #
    # example DEPRECATED usage:
    #   map "/uses" => "uses#index"
    def map(*args)
      warn "Router#map is deprecated, use Router#route instead"

      mapping = args.shift
      rest = args.shift || {}
      params = rest.fetch(:params, {})
      single_file = rest.fetch(:single_file, false)
      pp(
        mapping:, params:, single_file:,
      )

      mapping.each do |path, target|
        routes[path] = parse_target(target, params: params, single_file: single_file)
      end
    end

    # defines a new route
    #
    # example usage:
    #   route "/uses", to: "uses#index"
    def route(source, to:, params: {}, single_file: false)
      routes[source] = parse_target(to, params: params, single_file: single_file)
    end

    RESOURCE_ACTIONS = %i[index show].freeze

    def resources(name, path: name, only: RESOURCE_ACTIONS)
      actions = only.map(&:to_sym)
      base_name = name.to_s
      controller = controller_for(base_name)
      base_path = "/#{path}"

      # insert a route with id 0 as index if generate_all was specified, but without the /id in the path
      if actions.include?(:index)
        validate_controller_method(controller, :index)

        routes[base_path] = make_target(
          base_name: base_name,
          controller: controller,
          method_name: :index,
          params: { id: 0 },
          generate_all: nil,
          generate_all_ids: false
        )
      end

      actions.each do |action|
        method_name = action
        validate_controller_method(controller, method_name)

        generate_all = controller.instance_variable_get(:@__generate_all_for)&.[](method_name)
        generate_all_ids = controller.instance_variable_get(:@__generate_all_ids_for)&.[](method_name)

        route_path = method_name == :index ? base_path : "#{base_path}/#{method_name}"
        if generate_all
          # :show gets a pretty id, whereas :index (and others) get it prefixed with /page
          route_path = if generate_all_ids
                         "#{base_path}/%<id>s"
                       else
                         method_name == :show ? "#{base_path}/%<id>s" : "#{route_path}/page/%<id>s"
                       end
        end

        routes[route_path] ||= make_target(
          base_name: base_name,
          controller: controller,
          method_name: method_name,
          params: {},
          generate_all: generate_all,
          generate_all_ids: generate_all_ids
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

    def make_target(base_name:, controller:, method_name:, params: {}, generate_all: nil, generate_all_ids: false, single_file: false)
      OpenStruct.new(
        base_name: base_name,
        controller: controller,
        method_name: method_name,
        params: OpenStruct.new(params),
        generate_all: generate_all,
        generate_all_ids: generate_all_ids,
        single_file: single_file
      )
    end
  end
end
