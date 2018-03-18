module JSONAPI
  module Serializable
    require 'jsonapi/serializable/error'
    require 'jsonapi/serializable/resource'
    require 'jsonapi/serializable/renderer'

    # Error raised when there's no serializable class defined for resource.
    class UndefinedSerializableClass < StandardError; end

    # @api private
    def self.resources_for(objects, options, inferrer)
      return if objects.nil?

      if objects.respond_to?(:to_ary)
        Array(objects).map do |object|
          resource_for(object, options, inferrer)
        end
      else
        resource_for(objects, options, inferrer)
      end
    end

    def self.demodulize(path)
      path = path.to_s
      if i = path.rindex("::")
        path[(i + 2)..-1]
      else
        path
      end
    end

    # @api private
    def self.resource_for(object, options, inferrer)
      class_name = demodulize(object.class.name).to_sym

      serializable_klass = inferrer[class_name] || (
        raise UndefinedSerializableClass,
              "No serializable class defined for #{class_name}"
      )

      serializable_klass.new(options.merge(object: object))
    end
  end
end
