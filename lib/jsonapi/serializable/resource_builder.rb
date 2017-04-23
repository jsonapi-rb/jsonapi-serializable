module JSONAPI
  module Serializable
    class ResourceBuilder
      def initialize(inferrer = nil)
        @inferrer = inferrer
        @lookup_cache = {}

        freeze
      end

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

      def _build(object, expose, klass)
        serializable_class(object, klass).new(expose.merge(object: object))
      end

      # @api private
      def serializable_class(object, klass)
        klass = klass[object.class.name.to_sym] if klass.is_a?(Hash)

        @lookup_cache[[object.class.name, klass.to_s]] ||=
          reify_class(klass || @inferrer.call(object.class.name))
      end

      # @api private
      def reify_class(klass)
        if klass.is_a?(Class)
          klass
        elsif klass.is_a?(String)
          Object.const_get(klass)
        else
          # TODO(beauby): Raise meaningful exception.
        end
      end
    end
  end
end
