module JSONAPI
  module Serializable
    require 'jsonapi/serializable/error'
    require 'jsonapi/serializable/resource'
    require 'jsonapi/serializable/renderer'

    # Error raised when there's no serializable class defined for resource.
    class UndefinedSerializableClass < StandardError; end

    # @api private
    def self.class_for(object, inferrer)
      class_name = object.class.name.to_sym
      inferrer[class_name] || (
        raise UndefinedSerializableClass,
              "No serializable class defined for #{class_name}"
      )
    end
  end
end
