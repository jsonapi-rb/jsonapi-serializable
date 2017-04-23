require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Serializable
    class Renderer
      def self.render(objects, options = {})
        new(objects, options).render
      end

      def initialize(objects, options)
        @objects    = objects
        @options    = options.dup
        @klass      = @options.delete(:class)
        @namespace  = @options.delete(:namespace)
        inferrer    = @options.delete(:inferrer) || namespace_inferrer
        @resource_builder = JSONAPI::Serializable::ResourceBuilder.new(inferrer)
        @exposures = @options.delete(:expose) || {}
        @exposures[:_resource_builder] = @resource_builder

        freeze
      end

      def render
        JSONAPI.render(jsonapi_params.merge(data: jsonapi_resources)).to_json
      end

      private

      # @api private
      def jsonapi_params
        @options
      end

      # @api private
      def jsonapi_resources
        @resource_builder.build(@objects, @exposures, @klass)
      end

      # @api private
      def namespace_inferrer
        return nil unless @namespace
        proc do |class_name|
          names = class_name.split('::')
          klass = names.pop
          [@namespace, *names, "Serializable#{klass}"].reject(&:nil?).join('::')
        end
      end
    end

    class ErrorRenderer
      def self.render(errors, options)
        new(errors, options).render
      end

      def initialize(errors, options)
        @errors    = errors
        @options   = options.dup
      end

      def render
        JSONAPI.render(jsonapi_params.merge(errors: jsonapi_errors)).to_json
      end

      private

      # @api private
      def jsonapi_params
        @options
      end

      # @api private
      def jsonapi_errors
        @errors
      end
    end
  end
end
