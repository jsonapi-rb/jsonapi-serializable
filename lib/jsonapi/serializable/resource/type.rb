module JSONAPI
  module Serializable
    class Resource
      # Mixin to handle resource type.
      module Type
        def self.prepended(klass)
          super
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :type_val, :type_block
            end
          end
        end

        def initialize(*)
          super
          @_type = if self.class.type_block
                     instance_eval(&self.class.type_block).to_sym
                   else
                     self.class.type_val || :unknown
                   end
        end

        # @see JSONAPI::Serializable::Resource#as_jsonapi
        def as_jsonapi(*)
          super.tap do |hash|
            hash[:type] = @_type
          end
        end

        # DSL methods for declaring the resource type.
        module DSL
          def inherited(klass)
            super
            klass.type_val   = type_val
            klass.type_block = type_block
          end

          # @overload type(value)
          #   Declare the JSON API type of this resource.
          #   @param [String] value The value of the type.
          #
          #   @example
          #     type 'users'
          #
          # @overload type(&block)
          #   Declare the JSON API type of this resource.
          #   @yieldreturn [String] The value of the type.
          #   @example
          #     type do
          #       @object.type
          #     end
          def type(value = nil, &block)
            self.type_val   = value.to_sym if value
            self.type_block = block
          end
        end
      end
    end
  end
end
