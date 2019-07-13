# frozen_string_literal: true

module FoxPage
  module Refinements
    module Constantize
      refine String do
        def constantize
          Kernel.const_get(self)
        end
      end

      refine Symbol do
        def constantize
          to_s.constantize
        end
      end
    end
  end
end
