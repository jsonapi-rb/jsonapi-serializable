module JSONAPI
  module Serializable
    class Resource
      # Extension for caching dynamic attributes.
      #
      # @usage
      #   class SerializableUser < JSONAPI::Serializable::Resource
      #     extend JSONAPI::Serializable::Resource::Caching
      #
      #     # Optionally specify a subset of attributes to be cached.
      #     cached_attributes :name, :email
      #     ...
      #   end
      module Caching
        def self.extended(klass)
          klass.class_eval do
            class << self
              attr_accessor :_cached_attributes, :_attributes_cache
            end
            self._attributes_cache = Hash.new { |h, k| h[k] = {} }
            include InstanceMethods
          end
        end

        def inherited(klass)
          super
          klass._cached_attributes = _cached_attributes
          klass._attributes_cache = Hash.new { |h, k| h[k] = {} }
        end

        def cached_attributes(*attrs)
          self._cached_attributes = attrs
        end

        module InstanceMethods
          def _attribute_value(key, &block)
            if self.class._cached_attributes.nil? ||
               self.class._cached_attributes.include?(key)
              self.class._attributes_cache[jsonapi_id][key] ||= super
            else
              super
            end
          end
        end
      end
    end
  end
end
