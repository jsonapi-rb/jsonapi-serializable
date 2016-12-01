module JSONAPI
  module Serializable
    module ConditionalFields
      def self.prepended(klass)
        klass.class_eval do
          extend ClassMethods
          prepend InstanceMethods
          class << self
            attr_accessor :condition_blocks
          end
          self.condition_blocks ||= {}
        end
      end

      module ClassMethods
        def inherited(klass)
          super
          klass.condition_blocks = condition_blocks.dup
        end

        def _register_condition(name, conditions)
          condition_blocks[name.to_sym] =
            if conditions.key?(:if)
              conditions[:if]
            elsif conditions.key?(:unless)
              proc { !instance_exec(&conditions[:unless]) }
            end
        end

        def attribute(name, options = {}, &block)
          super
          _register_condition(name, options)
        end

        def relationship(name, options = {}, &block)
          super
          _register_condition(name, options)
        end
      end

      module InstanceMethods
        def _conditions
          self.class.condition_blocks
        end

        def requested_attributes(fields)
          super(fields).select do |k, _|
            _conditions[k].nil? || instance_exec(&_conditions[k])
          end
        end

        def requested_relationships(fields)
          super(fields).select do |k, _|
            _conditions[k].nil? || instance_exec(&_conditions[k])
          end
        end
      end
    end
  end
end
