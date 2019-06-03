# frozen_string_literal: true

require "thor"

module FoxPage
  class Generator < Thor::Group
    include Thor::Actions

    argument :name, type: :string, desc: "The name of your website"

    def self.source_root
      File.join(__dir__, "app_template")
    end

    def create_application
      Dir[File.join(self.class.source_root, "**/*.tt")]
        .map { |path| path.sub(self.class.source_root + "/", "") }
        .each do |path|
        template(path,
                 File.join(name,
                           path.sub(/\.tt$/, "")
                               .gsub(/__dot__/, ".")))
      end
    end

    def run_bundle
      Dir.chdir(name) do
        system("bundle install")
        system("bundle binstubs foxpage")
      end
    end

    def init_git_repo
      Dir.chdir(name) do
        system("git init")
        system("git add .")
      end
    end
  end
end
