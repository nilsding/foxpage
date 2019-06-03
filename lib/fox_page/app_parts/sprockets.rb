# frozen_string_literal: true

require "sprockets"

module FoxPage
  module AppParts
    module Sprockets
      extend Base

      attr_reader :sprockets

      init do
        env = ::Sprockets::Environment.new(root)
        env.append_path("app/assets/stylesheets")
        env.append_path("app/assets/images")

        manifest = ::Sprockets::Manifest.new(
          env, "./#{OUTPUT_DIRECTORY}/assets/.sprockets_manifest.json"
        )

        @sprockets = OpenStruct.new(
          env: env,
          manifest: manifest
        )
      end
    end
  end
end
