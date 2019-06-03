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
  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "zeitwerk", "~> 2.1"

  # templating
  spec.add_dependency "haml", "~> 5.1"
  spec.add_dependency "tilt", "~> 2.0"

  # assets
  spec.add_dependency "sassc", "~> 2.0"
  spec.add_dependency "sprockets", "~> 4.0.0.beta9"

  # interactive development server
  spec.add_dependency "listen", "~> 3.1"
  spec.add_dependency "webrick", "~> 1.4"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.68.1"
end
