# frozen_string_literal: true

module FoxPage
  module Refinements
    module Pluralize
      refine String do
        def pluralize
          return sub(/y$/, "ies") if end_with?("y")

          "#{self}s"
        end
      end
    end
  end
end
