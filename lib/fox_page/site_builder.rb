# frozen_string_literal: true

require "fileutils"

module FoxPage
  class SiteBuilder
    include Builders::Assets
    include Builders::FileCopy
    include Builders::Models
    include Builders::Pages

    def self.build(app)
      new(app).build
    end

    attr_reader :app, :output_directory

    def initialize(app)
      @app = app
      @output_directory = app.root.join(OUTPUT_DIRECTORY)
    end

    def build
      puts "==> Building site #{App.config.site&.title}"

      FileUtils.mkdir_p output_directory

      load_models
      build_assets
      build_pages
      copy_public_files
    end
  end
end
