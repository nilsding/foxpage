# frozen_string_literal: true

module FoxPage
  class Model
    using Refinements::Camelize
    using Refinements::Pluralize
    using Refinements::Singularize
    using Refinements::ToDeepOpenStruct
    using Refinements::Underscore

    @__data = []

    def self.inherited(subclass)
      subclass.reload_all(@__app)
    end

    def self.reload_all(app)
      data_name = name.to_s.underscore.pluralize
      puts "MODEL\t#{data_name}"
      @__data = YAML.load_file(
        app.root.join("data", data_name + ".yml")
      ).to_deep_ostruct.map { |ostruct| new(ostruct) }
    end

    # e.g. in ProjectCategory: has_many :projects, referenced_by: nil
    #
    # nil = default of self.class.name underscored
    def self.has_many(what, referenced_by: nil) # rubocop:disable Naming/PredicateName, Metrics/LineLength
      referenced_by ||= name.to_s.underscore
      association_class = Kernel.const_get(what.to_s.singularize.camelize)

      define_method(what.to_s) do
        association_class.where(referenced_by => name.to_s)
      end
    end

    # e.g. in Project: belongs_to :project_category, referenced_by: :name
    def self.belongs_to(what, referenced_by: :name)
      association_class = Kernel.const_get(what.to_s.camelize)

      define_method("__#{what}_value") do
        @__ostruct[what]
      end

      define_method(what) do
        association_class.find(referenced_by => public_send("__#{what}_value"))
      end
    end

    def self.all
      @__data
    end

    def self.each(&block)
      @__data.each(&block)
    end

    def self.find(filter)
      @__data.find do |object|
        filter.all? do |key, value|
          value_key_name = "__#{key}_value"
          key = value_key_name if object.respond_to?(value_key_name)

          object.public_send(key) == value
        end
      end
    end

    def self.where(filter)
      @__data.select do |object|
        filter.all? do |key, value|
          value_key_name = "__#{key}_value"
          key = value_key_name if object.respond_to?(value_key_name)

          object.public_send(key) == value
        end
      end
    end

    def initialize(ostruct)
      @__ostruct = ostruct
    end

    def method_missing(method, *args, &block)
      hash_ostruct = @__ostruct.to_h
      return super unless hash_ostruct.key?(method.to_sym)

      hash_ostruct[method.to_sym]
    end

    def respond_to_missing?(method, *)
      return true if @__ostruct.to_h.key?(method.to_sym)

      super
    end
  end
end
