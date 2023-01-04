# frozen_string_literal: true

lib = File.expand_path("./lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fox_page/version"

Gem::Specification.new do |spec|
  spec.name          = "foxpage"
  spec.version       = FoxPage::VERSION
  spec.authors       = ["Georg Gadinger"]
  spec.email         = ["nilsding@nilsding.org"]

  spec.summary       = "A Rails-like static page generator"
  spec.description   = "A very overengineered static-page generator"
  spec.homepage      = "https://github.com/nilsding/foxpage"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/nilsding/foxpage"
    # spec.metadata["changelog_uri"] = "... changelog.md ..."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # core
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "zeitwerk", "~> 2.6"

  # templating
  spec.add_dependency "haml", "~> 6.1"
  spec.add_dependency "tilt", "~> 2.0"

  # assets
  spec.add_dependency "sassc", "~> 2.4"
  spec.add_dependency "sprockets", "~> 4.2"

  # interactive development server
  spec.add_dependency "listen", "~> 3.7"
  spec.add_dependency "webrick", "~> 1.7"

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.42"
end
