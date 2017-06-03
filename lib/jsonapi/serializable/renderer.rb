require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Serializable
    class SuccessRenderer
      def render(resources, options = {})
        options   = options.dup
        klass     = options.delete(:class)
        namespace = options.delete(:namespace)
        inferrer  = options.delete(:inferrer) || namespace_inferrer(namespace)
        expose    = options.delete(:expose) || {}
        resource_builder = JSONAPI::Serializable::ResourceBuilder.new(inferrer)
        exposures = expose.merge(_resource_builder: resource_builder)

        resources = resource_builder.build(resources, exposures, klass)

        JSONAPI.render(options.merge(data: resources))
      end

      private

      # @api private
      def namespace_inferrer(namespace)
        proc do |class_name|
          names = class_name.split('::')
          klass = names.pop
          [namespace, *names, "Serializable#{klass}"].reject(&:nil?).join('::')
        end
      end
    end

    class ErrorRenderer
      def render(errors, options = {})
        JSONAPI.render(options.merge(errors: errors))
      end
    end
  end
end
