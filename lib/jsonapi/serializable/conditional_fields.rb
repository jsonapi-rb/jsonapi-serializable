module JSONAPI
  module Serializable
    module ConditionalFields
      def self.prepended(klass)
        klass.class_eval do
          extend ClassMethods
          prepend InstanceMethods
          class << klass
            attr_accessor :condition_blocks
          end
          self.condition_blocks = {}
        end
      end

      module ClassMethods
        def _register_condition(name, conditions)
          condition_blocks[name.to_sym] =
            if conditions.key?(:if)
              conditions[:if]
            elsif conditions.key?(:unless)
              proc { !conditions[:unless].call }
            end
        end

        def attribute(name, conditions = {})
          _register_condition(name, conditions)
          super(name)
        end

        def has_one(name, conditions = {})
          _register_condition(name, conditions)
          super(name)
        end

        def has_many(name, conditions = {})
          _register_condition(name, conditions)
          super(name)
        end

        def belongs_to(name, conditions = {})
          _register_condition(name, conditions)
          super(name)
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
