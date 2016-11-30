module JSONAPI
  module Serializable
    module KeyTransform
      def self.prepended(klass)
        klass.class_eval do
          extend ClassMethods
          class << self
            attr_accessor :key_transform
          end
        end
      end

      module ClassMethods
        def inherited(klass)
          super
          klass.key_transform = key_transform
        end

        def attribute(name, options = {}, &block)
          super(key_transform.call(name), options, &block)
        end

        def relationship(name, options = {}, &block)
          super(key_transform.call(name), options, &block)
        end
      end
    end
  end
end
