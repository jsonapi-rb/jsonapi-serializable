module JSONAPI
  module Serializable
    module ModelDSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def attribute(attr, &block)
          block ||= proc { @model.public_send(attr) }
          super(attr, &block)
        end

        # TODO(beauby): Allow Hash{String=>String} as resource_class value.
        def relationship(rel, resource_class = nil, &block)
          if resource_class.is_a?(String)
            resource_class = Object.const_get(resource_class)
          end
          rel_block = proc do
            data(resource_class) { @model.public_send(rel) }
            instance_eval(&block) unless block.nil?
          end
          super(rel, &rel_block)
        end
        alias has_many   relationship
        alias has_one    relationship
        alias belongs_to relationship
      end
    end
  end
end
