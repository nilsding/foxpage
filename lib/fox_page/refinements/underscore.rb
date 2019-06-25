# frozen_string_literal: true

module FoxPage
  module Refinements
    module Underscore
      refine String do
        def underscore
          gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
        end
      end
    end
  end
end
