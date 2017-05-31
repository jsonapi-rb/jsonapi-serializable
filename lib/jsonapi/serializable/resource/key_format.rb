module JSONAPI
  module Serializable
    class Resource
      # Extension for handling automatic key formatting of
      #   attributes/relationships.
      #
      # @usage
      #   class SerializableUser < JSONAPI::Serializable::Resource
      #     extend JSONAPI::Serializable::Resource::KeyFormat
      #     self.key_format = proc { |key| key.camelize }
      #
      #     attribute :user_name
      #     has_many :close_friends
      #   end
      #   # => will modify the serialized keys to `UserName` and `CloseFriends`.
      module KeyFormat
        def self.prepended(klass)
          warn <<-EOT
  DERPRECATION WARNING (called from #{caller_locations(1...2).first}):
  Prepending `#{name}' is deprecated and will be removed in future releases. Use `Object#extend' instead.
  EOT

          klass.extend self
        end

        def self.extended(klass)
          klass.class_eval do
            class << self
              attr_accessor :key_format
            end
          end
        end

        def inherited(klass)
          super
          klass.key_format = key_format
        end

        # Handles automatic key formatting for attributes.
        def attribute(name, options = {}, &block)
          block ||= proc { @object.public_send(name) }
          super(key_format.call(name), options, &block)
        end

        # Handles automatic key formatting for relationships.
        def relationship(name, options = {}, &block)
          rel_block = proc do
            data { @object.public_send(name) }
            instance_eval(&block) unless block.nil?
          end
          super(key_format.call(name), options, &rel_block)
        end

        # NOTE(beauby): Re-aliasing those is necessary for the
        #   overridden `#relationship` method to be called.
        alias has_many   relationship
        alias has_one    relationship
        alias belongs_to relationship
      end
    end
  end
end
