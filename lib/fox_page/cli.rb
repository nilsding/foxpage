# frozen_string_literal: true

require "thor"

module FoxPage
  class Cli < Thor
    desc "build", "Builds your website"
    def build
      app = require_application

      app.build
    end

    desc "server", "Runs a server for quick development"
    def server
      app = require_application

      app.server.start
    end

    register FoxPage::Generator,
             "new", "new NAME",
             "Create a new FoxPage website"

    private

    def require_application
      require File.join(Bundler.root, "config", "environment")

      ObjectSpace.each_object(Class).find do |klass|
        klass.superclass == FoxPage::Application
      end
    end
  end
end
