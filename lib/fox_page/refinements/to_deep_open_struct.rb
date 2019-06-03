# frozen_string_literal: true

require "ostruct"

module FoxPage
  module Refinements
    module ToDeepOpenStruct
      refine Array do
        def to_deep_ostruct
          map do |value|
            next value unless value.is_a?(Hash) || value.is_a?(Array)

            value.to_deep_ostruct
          end
        end
      end

      refine Hash do
        def to_deep_ostruct
          OpenStruct.new(
            dup.tap do |hash|
              hash.each do |key, value|
                next unless value.is_a?(Hash) || value.is_a?(Array)

                hash[key] = value.to_deep_ostruct
              end
            end
          )
        end
      end
    end
  end
end
