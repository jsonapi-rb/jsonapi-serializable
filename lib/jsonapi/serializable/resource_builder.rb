module JSONAPI
  module Serializable
    class ResourceBuilder
      DEFAULT_RESOURCE_INFERRER = lambda do |object_klass_name|
        names = object_klass_name.split('::'.freeze)
        klass_name = names.pop
        namespace = names.join('::'.freeze)

        klass_name = [namespace, "Serializable#{klass_name}"]
                     .reject(&:nil?)
                     .reject(&:empty?)
                     .join('::'.freeze)

        Object.const_get(klass_name)
      end

      def initialize(inferrer = nil)
        @inferrer = inferrer || DEFAULT_RESOURCE_INFERRER

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
      # rubocop:disable Metrics/MethodLength
      def serializable_class(object, klass)
        klass =
          if klass.nil?
            @inferrer.call(object.class.name)
          elsif klass.is_a?(Hash)
            klass[object.class.name.to_sym]
          else
            klass
          end

        reify_class(klass)
      end
      # rubocop:enable Metrics/MethodLength

      # @api private
      def reify_class(klass)
        if klass.is_a?(Class)
          klass
        elsif klass.is_a?(String)
          Object.const_get(klass)
        else
          # TODO(beauby): Raise meaningful exception.
          raise
        end
      end
    end
  end
end
