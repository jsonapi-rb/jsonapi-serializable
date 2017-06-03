module JSONAPI
  module Serializable
    class ResourceBuilder
      # @api private
      def initialize(inferrer = nil)
        @inferrer = inferrer
        @lookup_cache = {}

        freeze
      end

      # @api private
      def build(objects, expose, klass = nil)
        return objects if objects.nil? ||
                          Array(objects).first.respond_to?(:as_jsonapi)

        if objects.respond_to?(:to_ary)
          Array(objects).map { |obj| _build(obj, expose, klass) }
        else
          _build(objects, expose, klass)
        end
      end

      private

      # @api private
      def _build(object, expose, klass)
        serializable_class(object.class.name, klass)
          .new(expose.merge(object: object))
      end

      # @api private
      def serializable_class(object_class_name, klass)
        klass = klass[object_class_name.to_sym] if klass.is_a?(Hash)

        @lookup_cache[[object_class_name, klass.to_s]] ||=
          reify_class(klass || @inferrer.call(object_class_name))
      end

      # @api private
      def reify_class(klass)
        if klass.is_a?(Class)
          klass
        elsif klass.is_a?(String) || klass.is_a?(Symbol)
          begin
            Object.const_get(klass)
          rescue NameError
            raise NameError, "Undefined serializable class #{klass}"
          end
        else
          raise ArgumentError, "Invalid serializable class #{klass}"
        end
      end
    end
  end
end
