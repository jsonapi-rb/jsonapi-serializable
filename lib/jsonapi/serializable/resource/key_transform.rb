module JSONAPI
  module Serializable
    class Resource
      # Extension for handling automatic key transformations of
      #   attributes/relationships.
      #
      # @usage
      #   class SerializableUser < JSONAPI::Serializable::Resource
      #     prepend JSONAPI::Serializable::Resource::KeyTransform
      #     self.key_transform = proc { |key| key.camelize }
      #
      #     attribute :user_name
      #     has_many :close_friends
      #   end
      #   # => will modify the serialized keys to `UserName` and `CloseFriends`.
      module KeyTransform
        def self.prepended(klass)
          klass.class_eval do
            extend ClassMethods
            class << self
              attr_accessor :key_transform
            end
          end
        end

        # DSL extensions for automatic key transformations.
        module ClassMethods
          def inherited(klass)
            super
            klass.key_transform = key_transform
          end

          # Handles automatic key transformation for attributes.
          def attribute(name, options = {}, &block)
            super(key_transform.call(name), options, &block)
          end

          # Handles automatic key transformation for relationships.
          def relationship(name, options = {}, &block)
            super(key_transform.call(name), options, &block)
          end
        end
      end
    end
  end
end
