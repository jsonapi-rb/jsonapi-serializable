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
        return objects if objects.nil? ||
                          Array(objects).first.respond_to?(:as_jsonapi)

        if objects.respond_to?(:each)
          objects.map { |obj| new(obj, expose, klass).resource }
        else
          new(objects, expose, klass).resource
        end
      end

      attr_reader :resource

      def initialize(object, expose, klass)
        @object   = object
        @expose   = expose || {}
        @klass    = klass
        @resource = serializable_class.new(serializable_params)
        freeze
      end

      private

      def serializable_params
        @expose.merge(object: @object)
      end

      # rubocop:disable Metrics/MethodLength
      def serializable_class
        klass =
          if @klass.respond_to?(:call)
            @klass.call(@object.class.name)
          elsif @klass.is_a?(Hash)
            @klass[@object.class.name.to_sym]
          elsif @klass.nil?
            DEFAULT_RESOURCE_INFERER.call(@object.class.name)
          else
            @klass
          end

        reify_class(klass)
      end
      # rubocop:enable Metrics/MethodLength

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
