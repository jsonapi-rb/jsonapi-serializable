module JSONAPI
  module Serializable
    module ConditionalFields
      def self.prepended(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
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
          self.class.attribute_blocks
            .select { |k, _| fields.nil? || fields.include?(k) }
            .select { |k, _| _conditions[k].nil? || _conditions[k].call }
            .each_with_object({}) { |(k, v), h| h[k] = instance_eval(&v) }
        end

        def requested_relationships(fields, include)
          @_relationships
            .select { |k, _| fields.nil? || fields.include?(k) }
            .select { |k, _| _conditions[k].nil? || _conditions[k].call }
            .each_with_object({}) do |(k, v), h|
            h[k] = v.as_jsonapi(include.include?(k))
          end
        end
      end
    end
  end
end
