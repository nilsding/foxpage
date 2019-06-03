# frozen_string_literal: true

require "sprockets"

module FoxPage
  module Builders
    module Assets
      def build_assets
        all_assets.each do |asset|
          puts "ASSET\t#{asset}"
          app.sprockets.manifest.compile(asset)
        end
      end

      private

      def all_assets
        app.config.assets + image_assets
      end

      def image_assets
        image_assets_path = app.root.join("app/assets/images")
        Dir.glob("#{image_assets_path}/**/*.{png,jpg,gif,jpeg}")
           .map { |full_path| full_path.sub(%r{\A#{image_assets_path}/}, "") }
      end
    end
  end
end
