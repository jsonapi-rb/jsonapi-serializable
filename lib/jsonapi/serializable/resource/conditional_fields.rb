module JSONAPI
  module Serializable
    class Resource
      # Extension for handling conditional fields in serializable resources.
      #
      # @usage
      #   class SerializableUser < JSONAPI::Serializable::Resource
      #     prepend JSONAPI::Serializable::Resource::ConditionalFields
      #
      #     attribute :email, if: -> { @current_user.admin? }
      #     has_many :friends, unless: -> { @object.private_profile? }
      #   end
      #
      module ConditionalFields
        def self.prepended(klass)
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :condition_blocks
            end
            self.condition_blocks ||= {}
          end
        end

        # DSL extensions for conditional fields.
        module DSL
          def inherited(klass)
            super
            klass.condition_blocks = condition_blocks.dup
          end

          # Handle the `if` and `unless` options for attributes.
          #
          # @example
          #   attribute :email, if: -> { @current_user.admin? }
          #
          def attribute(name, options = {}, &block)
            super
            _register_condition(name, options)
          end

          # Handle the `if` and `unless` options for relationships (has_one,
          #   belongs_to, has_many).
          #
          # @example
          #   has_many :friends, unless: -> { @object.private_profile? }
          #
          def relationship(name, options = {}, &block)
            super
            _register_condition(name, options)
          end

          # NOTE(beauby): Re-aliasing those is necessary for the
          #   overridden `#relationship` method to be called.
          alias has_many   relationship
          alias has_one    relationship
          alias belongs_to relationship

          # @api private
          def _register_condition(name, options)
            condition_blocks[name.to_sym] =
              if options.key?(:if)
                options[:if]
              elsif options.key?(:unless)
                proc { !instance_exec(&options[:unless]) }
              end
          end
        end

        # @api private
        def requested_attributes(fields)
          super.select { |k, _| _conditionally_included?(k) }
        end

        # @api private
        def requested_relationships(fields)
          super.select { |k, _| _conditionally_included?(k) }
        end

        # @api private
        def _conditionally_included?(field)
          condition = self.class.condition_blocks[field]
          condition.nil? || instance_exec(&condition)
        end
      end
    end
  end
end
