# frozen_string_literal: true

module FoxPage
  module Refinements
    module Camelize
      refine String do
        def camelize
          split("_").map(&:capitalize).join
        end
      end

      refine Symbol do
        def camelize
          to_s.camelize.to_sym
        end
      end
    end
  end
end
