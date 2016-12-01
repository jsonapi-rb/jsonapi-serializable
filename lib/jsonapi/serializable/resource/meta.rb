module JSONAPI
  module Serializable
    class Resource
      module Meta
        def self.prepended(klass)
          super
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :meta_val, :meta_block
            end
          end
        end

        def initialize(*)
          super
          @_meta = if self.class.meta_block
                     instance_eval(&self.class.meta_block)
                   else
                     self.class.meta_val
                   end
        end

        def as_jsonapi(*)
          super.tap do |hash|
            hash[:meta] = @_meta unless @_meta.nil?
          end
        end

        module DSL
          def inherited(klass)
            super
            klass.meta_val   = meta_val
            klass.meta_block = meta_block
          end

          # @overload meta(value)
          #   Declare the meta information for this resource.
          #   @param [Hash] value The meta information hash.
          #
          #   @example
          #     meta key: value
          #
          # @overload meta(&block)
          #   Declare the meta information for this resource.
          #   @yieldreturn [String] The meta information hash.
          #   @example
          #     meta do
          #       { key: value }
          #     end
          def meta(value = nil, &block)
            self.meta_val = value
            self.meta_block = block
          end
        end
      end
    end
  end
end
