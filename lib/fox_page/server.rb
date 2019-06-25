# frozen_string_literal: true

require "listen"
require "webrick"

module FoxPage
  class Server
    def initialize(app)
      @app = app
      @listener = Listen.to(app.root.join("app"),
                            app.root.join("data"),
                            app.root.join("public"),
                            &method(:handle_modified_app))
      @server = WEBrick::HTTPServer.new(
        BindAddress: ENV.fetch("APP_BIND", "127.0.0.1"),
        Port: ENV.fetch("APP_PORT", 3000).to_i,
        DocumentRoot: app.root.join(OUTPUT_DIRECTORY)
      )
    end

    def start
      puts "==> Starting up development server at " \
           "http://#{@server.config[:BindAddress]}:#{@server.config[:Port]}"

      trap "INT" do
        @server.shutdown
      end

      @app.build
      @listener.start
      @server.start
    end

    def handle_modified_app(_modified, _added, _removed)
      reload_code
      @app.build
    rescue Exception => e # rubocop:disable Lint/RescueException
      # need to rescue Exception as syntax errors may cause the builds to break
      puts "!!! An error occurred while building the app"
      puts e.full_message
    end

    def reload_code
      @app.code_loader.reload
      @app.reload_routes!
    end
  end
end
