# frozen_string_literal: true

module FoxPage
  module Refinements
    module Singularize
      refine String do
        def singularize
          return sub(/ies$/, "y") if end_with?("ies")

          sub(/s$/, "")
        end
      end
    end
  end
end
