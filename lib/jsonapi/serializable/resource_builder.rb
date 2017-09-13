module JSONAPI
  module Serializable
    class ResourceBuilder
      # @api private
      def self.build(objects, options, inferrer)
        new(inferrer).build(objects, options)
      end

      # @api private
      def initialize(inferrer)
        @inferrer = inferrer

        freeze
      end

      # @api private
      def build(objects, options)
        return if objects.nil?

        if objects.respond_to?(:to_ary)
          Array(objects).map { |object| build_resource(object, options) }
        else
          build_resource(objects, options)
        end
      end

      private

      # @api private
      def build_resource(object, options)
        class_name = object.class.name.to_sym

        serializable_klass = @inferrer[class_name] || (
          raise UndefinedSerializableClass,
                "No serializable class defined for #{class_name}"
        )

        serializable_klass.new(options.merge(object: object))
      end
    end

    # Error raised when there's no serializable class defined for object.
    class UndefinedSerializableClass < StandardError; end
  end
end
