module JSONAPI
  module Serializable
    module ResourceBuilder
      class << self
        # @api private
        def build(objects, options, inferrer)
          return if objects.nil?

          if objects.respond_to?(:to_ary)
            Array(objects).map do |object|
              build_resource(object, options, inferrer)
            end
          else
            build_resource(objects, options, inferrer)
          end
        end

        private

        # @api private
        def build_resource(object, options, inferrer)
          class_name = object.class.name.to_sym

          serializable_klass = inferrer[class_name] || (
            raise UndefinedSerializableClass,
                  "No serializable class defined for #{class_name}"
          )

          serializable_klass.new(options.merge(object: object))
        end
      end
    end

    # Error raised when there's no serializable class defined for object.
    class UndefinedSerializableClass < StandardError; end
  end
end
