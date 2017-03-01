module JSONAPI
  module Serializable
    class ResourceBuilder
      DEFAULT_RESOURCE_INFERER = lambda do |object_klass_name|
        names = object_klass_name.split('::'.freeze)
        klass_name = names.pop
        namespace = names.join('::'.freeze)

        klass_name = [namespace, "Serializable#{klass_name}"]
                     .reject(&:nil?)
                     .reject(&:empty?)
                     .join('::'.freeze)

        Object.const_get(klass_name)
      end

      def self.build(objects, expose, klass)
        return nil if objects.nil?
        unless objects.respond_to?(:to_ary)
          return build([objects], expose, klass).first
        end

        return objects if Array(objects).first.respond_to?(:as_jsonapi)

        Array(objects).map { |obj| new(obj, expose, klass).resource }
      end

      attr_reader :resource

      def initialize(object, expose, klass)
        serializable_class  = serializable_class(object, klass)
        serializable_params = serializable_params(object, expose || {})
        @resource = serializable_class.new(serializable_params)
        freeze
      end

      private

      # @api private
      def serializable_params(object, exposures)
        exposures.merge(object: object)
      end

      # @api private
      # rubocop:disable Metrics/MethodLength
      def serializable_class(object, klass)
        klass =
          if klass.respond_to?(:call)
            klass.call(object.class.name)
          elsif klass.is_a?(Hash)
            klass[object.class.name.to_sym]
          elsif klass.nil?
            DEFAULT_RESOURCE_INFERER.call(object.class.name)
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
