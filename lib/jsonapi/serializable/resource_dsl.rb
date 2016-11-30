module JSONAPI
  module Serializable
    module ResourceDSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def attribute(attr, _options = {}, &block)
          block ||= proc { @object.public_send(attr) }
          super(attr, &block)
        end

        def attributes(*args)
          args.each do |attr|
            attribute(attr)
          end
        end

        def relationship(rel, options = {}, &block)
          rel_block = proc do
            data(options[:class]) { @object.public_send(rel) }
            instance_eval(&block) unless block.nil?
          end
          super(rel, options, &rel_block)
        end
        alias has_many   relationship
        alias has_one    relationship
        alias belongs_to relationship
      end
    end
  end
end
