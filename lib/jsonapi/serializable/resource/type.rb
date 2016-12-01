module JSONAPI
  module Serializable
    class Resource
      module Type
        def self.prepended(klass)
          super
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :type_val
            end
          end
        end

        def initialize(*)
          super
          @_type = self.class.type_val || :unknown
        end

        def as_jsonapi(*)
          super.tap do |hash|
            hash[:type] = @_type
          end
        end

        module DSL
          def inherited(klass)
            super
            klass.type_val = type_val
          end

          # Declare the JSON API type of this resource.
          # @param [String] value The value of the type.
          #
          # @example
          #   type 'users'
          def type(value)
            self.type_val = value.to_sym
          end
        end
      end
    end
  end
end
