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

        def has_many(rel, resource_class = nil, &block)
          if resource_class.is_a?(String)
            resource_class = Object.const_get(resource_class)
          end
          rel_block = proc do
            data do
              @model.public_send(rel).map do |related|
                resource_class ||= Model.resource_klass_for(related.class.name)
                resource_class.new(@_param_hash.merge(model: related))
              end
            end
            instance_eval(&block) unless block.nil?
          end
          relationship(rel, &rel_block)
        end

        def has_one(rel, resource_class = nil, &block)
          if resource_class.is_a?(String)
            resource_class = Object.const_get(resource_class)
          end
          rel_block = proc do
            data do
              related = @model.public_send(rel)
              if related.nil?
                nil
              else
                resource_class ||= Model.resource_klass_for(related.class.name)
                resource_class.new(@_param_hash.merge(model: related))
              end
            end
            instance_eval(&block) unless block.nil?
          end
          relationship(rel, &rel_block)
        end
      end
    end
  end
end
