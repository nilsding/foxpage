# frozen_string_literal: true

require "yaml"

module FoxPage
  class Model
    using Refinements::Camelize
    using Refinements::Pluralize
    using Refinements::Singularize
    using Refinements::ToDeepOpenStruct
    using Refinements::Underscore

    @__data = []

    VALID_STORAGE_TYPES = %i[yaml dir].freeze
    DEFAULT_STORAGE_TYPE = :yaml
    private_constant :VALID_STORAGE_TYPES
    private_constant :DEFAULT_STORAGE_TYPE

    def self.[](storage_type = DEFAULT_STORAGE_TYPE, storage_type_opts = {})
      unless VALID_STORAGE_TYPES.include?(storage_type)
        raise ArgumentError,
              "type must be one of #{VALID_STORAGE_TYPES.join(',')}"
      end

      @__tmp_storage_type = storage_type
      @__tmp_storage_type_opts = storage_type_opts

      self
    end

    def self.inherited(subclass)
      set_ivar_if_unset subclass, :@__storage_type, @__tmp_storage_type || DEFAULT_STORAGE_TYPE
      set_ivar_if_unset subclass, :@__storage_type_opts, @__tmp_storage_type_opts || {}

      subclass.reload_all(@__app)
    end

    def self.set_ivar_if_unset(subclass, ivar, value)
      return if subclass.instance_variable_get(ivar)

      subclass.instance_variable_set ivar, value
    end
    private_class_method :set_ivar_if_unset

    def self.reload_all(app)
      data_name = name.to_s.underscore.pluralize
      puts "MODEL\t#{data_name}"

      case @__storage_type
      when :yaml
        @__data = YAML.load_file(
          app.root.join("data", data_name + ".yml")
        ).to_deep_ostruct.map { |ostruct| new(ostruct) }
      when :dir
        default_opts = { extension: :md }
        opts = default_opts.merge(@__storage_type_opts)
        files = Dir[app.root.join("data", data_name, "*.#{opts.fetch(:extension)}")]

        @__data = files.map do |fn|
          id = File.basename(fn, ".#{opts.fetch(:extension)}")
          content = IO.read(fn)

          front_matter = {}
          if content =~ /\A(---\n.*\n)^(?:---)\s*$\n?/m
            content = Regexp.last_match.post_match
            front_matter = YAML.safe_load(Regexp.last_match[1])
          end

          new front_matter.merge(id: id, content: content).to_deep_ostruct
        end
      end
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

    # define a parser method for attributes
    # @example
    #   require "time"
    #
    #   class BlogPost < FoxPage::Model[:dir]
    #     def_parser :date do |date|
    #       Time.parse(date)
    #     end
    #   end
    #
    #   # in the blog posts' front matter:
    #   # ---
    #   # title: foo
    #   # date: Sat 13 Jul 13:38:43 CEST 2019
    #   # ---
    #
    #   # then, anywhere else:
    #   blog_post.date        # => 2019-07-13 13:38:43 +0200
    #   blog_post.date.class  # => Time
    def self.def_parser(attribute, &parser)
      define_method(attribute) do
        parser.call(@__ostruct[attribute])
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
