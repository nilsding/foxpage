# frozen_string_literal: true

require "sprockets"

module FoxPage
  module Helpers
    module AssetsHelper
      def asset_path(source)
        File.join("/assets", app.sprockets.manifest.assets[source])
      end

      def stylesheet_link_tag(source)
        %(<link rel="stylesheet" href=#{asset_path(source).inspect} />)
      end
    end
  end
end
