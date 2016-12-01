module JSONAPI
  module Serializable
    class AbstractResource
      module Attributes
        def self.prepended(klass)
          super
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :attribute_blocks
            end
            self.attribute_blocks = {}
          end
        end

        def initialize(*)
          super
          @_attributes = {}
        end

        def as_jsonapi(fields: nil, include: [])
          super.tap do |hash|
            attrs =
              requested_attributes(fields).each_with_object({}) do |(k, v), h|
                h[k] = instance_eval(&v)
              end
            hash[:attributes] = attrs if attrs.any?
          end
        end

        # @api private
        def requested_attributes(fields)
          self.class.attribute_blocks
              .select { |k, _| fields.nil? || fields.include?(k) }
        end

        module DSL
          def inherited(klass)
            super
            klass.attribute_blocks = attribute_blocks.dup
          end

          # Declare an attribute for this resource.
          #
          # @param [Symbol] name The key of the attribute.
          # @yieldreturn [Hash, String, nil] The block to compute the value.
          #
          # @example
          #   attribute(:name) { @user.name }
          def attribute(name, _options = {}, &block)
            attribute_blocks[name.to_sym] = block
          end
        end
      end
    end
  end
end
