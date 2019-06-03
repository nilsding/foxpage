# frozen_string_literal: true

module FoxPage
  module AppParts
    def self.initializers_for(klass)
      app_parts
        .select { |mod, _| klass.ancestors.include?(mod) }
        .values
        .sort { |a, b| (a[:priority] || 99) <=> (b[:priority] || 99) }
        .map { |x| x[:block] }
        .compact
    end

    def self.[](klass)
      app_parts[klass] ||= {}
      app_parts[klass]
    end

    def self.app_parts
      @app_parts ||= {}
    end
    private_class_method :app_parts
  end
end
