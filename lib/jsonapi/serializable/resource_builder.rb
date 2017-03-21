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
        inferrer ||= DEFAULT_RESOURCE_INFERRER
        define_singleton_method('infer_resource_class', &inferrer)
        @_cache = {}
        freeze
      end

      def build(objects, expose, klass)
        return nil if objects.nil?

        if objects.respond_to?(:to_ary)
          Array(objects).map { |obj| serializable_resource(obj, expose, klass) }
        else
          serializable_resource(objects, expose, klass)
        end
      end

      private

      # @api private
      def serializable_resource(obj, expose, klass)
        return obj if obj.respond_to?(:as_jsonapi)

        serializable_class(obj, klass).new(expose.merge(object: obj))
      end

      # @api private
      def serializable_class(obj, klass)
        klass_name = obj.class.name
        @_cache[[klass_name, klass]] ||=
          begin
            if klass.nil?
              klass = infer_resource_class(klass_name)
            elsif klass.is_a?(Hash)
              klass = klass[klass_name.to_sym]
            end

            if klass.is_a?(Class)
              klass
            else
              Object.const_get(klass)
            end
          end
      end
    end
  end
end
