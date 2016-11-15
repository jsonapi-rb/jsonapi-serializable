module JSONAPI
  module Serializable
    class ResourceBuilder
      DEFAULT_RESOURCE_INFERER = lambda do |model_klass_name|
        names = model_klass_name.split('::'.freeze)
        klass_name = names.pop
        namespace = names.join('::'.freeze)

        klass_name = [namespace, "Serializable#{klass_name}"]
                     .reject(&:nil?)
                     .reject(&:empty?)
                     .join('::'.freeze)

        Object.const_get(klass_name)
      end

      def self.build(models, expose, klass)
        return models if models.nil? ||
                         Array(models).first.respond_to?(:as_jsonapi)

        resources =
          Array(models).map { |model| new(model, expose, klass).resource }

        models.respond_to?(:each) ? resources : resources.first
      end

      attr_reader :resource

      def initialize(model, expose, klass)
        @model    = model
        @expose   = expose || {}
        @klass    = klass
        @resource = serializable_class.new(serializable_params)
        freeze
      end

      private

      def serializable_params
        @expose.merge(model: @model)
      end

      # rubocop:disable Metrics/MethodLength
      def serializable_class
        klass =
          if @klass.respond_to?(:call)
            @klass.call(@model.class.name)
          elsif @klass.is_a?(Hash)
            @klass[@model.class.name.to_sym]
          elsif @klass.nil?
            DEFAULT_RESOURCE_INFERER.call(@model.class.name)
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
