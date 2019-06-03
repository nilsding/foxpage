# frozen_string_literal: true

module FoxPage
  module Builders
    module FileCopy
      def copy_public_files
        puts "COPY\tpublic/* => #{OUTPUT_DIRECTORY}/"
        FileUtils.cp_r public_path, output_path
      end

      private

      def public_path
        app.root.join("public", ".")
      end

      def output_path
        app.root.join(OUTPUT_DIRECTORY)
      end
    end
  end
end
