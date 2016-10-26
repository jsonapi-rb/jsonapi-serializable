module JSONAPI
  module Serializable
    module ModelDSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def api_version(value)
          self.api_version_val = value
        end

        def type(value = nil)
          value ||= name
          super(value)
        end

        def attribute(attr, &block)
          block ||= proc { @model.public_send(attr) }
          super(attr, &block)
        end

        def has_many(rel, resource_klass = nil, &block)
          rel_block = proc do
            if resource_klass
              data do
                @model.public_send(rel).map do |related|
                  resource_klass ||= resource_klass_for(related.class)
                  resource_klass.new(model: related)
                end
              end
            end
            instance_eval(&block) unless block.nil?
          end
          relationship(rel, &rel_block)
        end

        def has_one(rel, resource_klass = nil, &block)
          rel_block = proc do
            if resource_klass
              data do
                related = @model.public_send(rel)
                resource_klass ||= resource_klass_for(related.class)
                resource_klass.new(model: related)
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
