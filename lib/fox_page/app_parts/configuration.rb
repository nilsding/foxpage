# frozen_string_literal: true

module FoxPage
  module AppParts
    module Configuration
      extend Base

      using Refinements::ToDeepOpenStruct

      attr_reader :root, :code_loader, :config

      priority 0

      init do
        # Set up the app root
        @root = Bundler.root

        # Convenience method for yours truly.
        # It's much easier to write `App.root.join(...)` instead
        # of `File.join(App.root, ...)`
        def @root.join(*path)
          File.join(self, *path)
        end

        # Set up application code loader
        @code_loader = Zeitwerk::Loader.new.tap do |loader|
          loader.push_dir(@root.join("app/controllers"))
          loader.push_dir(@root.join("app/models"))
          loader.push_dir(@root.join("app/helpers"))
          loader.enable_reloading
          loader.setup
        end

        # Finally, load the config.
        @config = load_config
      end

      private

      def load_config
        YAML
          .load_file(root.join("config", "site.yml"))
          .to_deep_ostruct
      end
    end
  end
end
