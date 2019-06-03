# frozen_string_literal: true

require "singleton"
require "forwardable"
require "yaml"

module FoxPage
  class Application
    include Singleton

    prepend AppParts::Builder
    prepend AppParts::Configuration
    prepend AppParts::Routes
    prepend AppParts::Server
    prepend AppParts::Sprockets

    def initialize!
      AppParts.initializers_for(self.class).each do |proc|
        instance_eval(&proc)
      end
    end

    # delegate _ALL_ the things!
    self.class.extend Forwardable
    (instance.public_methods - Object.methods)
      .reject { |x| x.to_s.start_with?("_") }
      .each do |meth|
      self.class.def_delegator :instance, meth
    end
  end
end
