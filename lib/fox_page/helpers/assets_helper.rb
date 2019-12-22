# frozen_string_literal: true

require "sprockets"

module FoxPage
  module Helpers
    module AssetsHelper
      def asset_path(source, prepend: "")
        prepend +
          File.join("/assets", app.sprockets.manifest.assets[source])
      end

      def stylesheet_link_tag(source, prepend: "")
        %(<link rel="stylesheet" href=#{asset_path(source, prepend: prepend).inspect} />)
      end

      def javascript_include_tag(source, prepend: "")
        %(<script language="JavaScript" src=#{asset_path(source, prepend: prepend).inspect}></script>)
      end
    end
  end
end
