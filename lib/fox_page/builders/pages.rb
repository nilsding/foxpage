# frozen_string_literal: true

require "tilt"
require "fileutils"

# Haml >= 6 ships its own template, so let the old Tilt version know about it.
require "haml"
Tilt::HamlTemplate = Haml::Template
# use old default from Haml 5
Haml::Template.options[:escape_html] = false

module FoxPage
  module Builders
    module Pages
      using Refinements::Camelize
      using Refinements::Constantize

      def build_pages
        app.routes.each do |path, route|
          if route.generate_all
            build_all_the_pages(path, route)
            next
          end

          build_single_page(path, route)
        end
      end

      def build_all_the_pages(path, route)
        enumerable =
          if route.generate_all.is_a?(Symbol)
            model = route.generate_all.camelize.constantize
            model.all
          else
            route.generate_all.call
          end

        enumerable.each_with_index do |item, index|
          if route.generate_all_ids
            # generate_all returns ids
            id = enumerable.at(index)
            target_path = format(path, id: id)
          else
            id = (item.respond_to?(:id) && item.id) || index
            # have page numbers start with 1
            target_path = format(path, id: id == index ? id + 1 : id)
          end

          build_single_page(target_path, route, id: id)
        end
      end

      def build_single_page(target_path, route, params = {})
        if params.empty?
          params_log_str = ""
        else
          params_log_str = "(#{params.inspect})"
          route = route.dup
          route.params = OpenStruct.new(route.params.to_h.merge(params))
        end

        puts "PAGE\t#{target_path} => #{route.base_name}##{route.method_name}#{params_log_str}"

        target_file = File.join(output_directory, target_path)
        unless route.single_file
          FileUtils.mkdir_p(target_file)
          target_file = File.join(target_file, "index.html")
        end

        File.open(target_file, "w") do |f|
          f.puts render_route(route, target_path)
        end
      end

      def render_route(route, path)
        controller = spiced_controller(route, path).new
        controller.method(route.method_name).call

        layout = layout_for(controller, route)
        page = Tilt.new(page_path(route))

        controller.instance_eval do
          if layout
            layout.render(self) { page.render(self) }
          else
            page.render(self)
          end
        end
      end

      # for the sake of keeping the original classes sane while building, we
      # create a subclass of the original dynamically and inject common helpers
      # to it and also run before_actions
      def spiced_controller(route, path) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/LineLength
        Class.new(route.controller).tap do |klass| # rubocop:disable Metrics/BlockLength, Metrics/LineLength
          klass.include(Helpers::AppHelper.new(app))
          klass.include(Helpers::AssetsHelper)
          klass.include(Helpers::RenderHelper)
          klass.include(Helpers::TagHelper)

          # include global ApplicationHelper if possible
          begin
            klass.include(ApplicationHelper)
          rescue NameError # rubocop:disable Lint/HandleExceptions
            # we don't have a global ApplicationHelper... which is fine
          end

          # find a controller-specific helper class and include it if we can
          begin
            helper = Kernel.const_get("#{route.base_name}_helper".camelize)
            klass.include(helper)
          rescue NameError # rubocop:disable Lint/HandleExceptions
            # same difference
          end

          klass.define_method(:params) do
            route.params
          end

          klass.define_method(:current_path) do
            path
          end

          klass.define_method(:current_controller_name) do
            route.base_name
          end

          klass.define_method(:inspect) do |*args|
            # report that we are actually the controller, not some random
            # anonymous class
            # append a + to it to indicate that it's different than an ordinary
            # class instance
            super(*args).sub(/#<Class:[^>]+>/, "#{route.controller}+")
          end

          klass.define_singleton_method(:inspect) do
            # for .ancestors to show up correctly
            "#{route.controller}+"
          end

          klass.define_method(:to_s) do |*args|
            # irb uses this method for displaying in the prompt
            super(*args).sub(/#<Class:[^>]+>/, "#{route.controller}+")
          end

          # inject filters
          route.controller.public_instance_methods(false).each do |method|
            klass.define_method(method) do |*args|
              # @__before_actions is set on the original class -- use it from
              # that one
              route.controller.instance_variable_get(:@__before_actions)&.each do |action| # rubocop:disable Metrics/LineLength
                send(action)
              end
              super(*args)
            end
          end
        end
      end

      def layout_for(controller, route)
        layout = controller.class.superclass.instance_variable_get(:@__use_layout_for)&.[](route.method_name)
        return if layout == false

        Tilt.new(layout_path(controller, layout))
      end

      def layout_path(controller, layout)
        layout ||= controller.class.layout

        File
          .join(views_path, layout)
          .tap(&method(:validate_file_exists))
      end

      def page_path(route)
        Dir
          .glob(
            File.join(views_path, route.base_name, "#{route.method_name}.*")
          )
          .first
          .tap { |file| validate_file_exists(file, route) }
      end

      def views_path
        @views_path ||= app.root.join("app", "views")
      end

      def validate_file_exists(file, route = nil)
        return if file && File.exist?(file)

        error_message = if route
                          "template for #{route.base_name}##{route.method_name}"
                        else
                          "layout template"
                        end

        raise ArgumentError, "Could not find #{error_message}"
      end
    end
  end
end
