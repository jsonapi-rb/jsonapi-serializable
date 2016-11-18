require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Serializable
    class Renderer
      def self.render(objects, options)
        new(objects, options).render
      end

      def initialize(objects, options)
        @objects    = objects
        @options    = options.dup
        @klass      = @options.delete(:class)
        @namespace  = @options.delete(:namespace)
        @inferer    = @options.delete(:inferer)
        @exposures  = @options.delete(:expose) || {}
        @exposures[:_resource_inferer] = namespace_inferer || @inferer
      end

      def render
        JSONAPI.render(jsonapi_params.merge(data: jsonapi_resources)).to_json
      end

      private

      def jsonapi_params
        @options
      end

      def jsonapi_resources
        toplevel_inferer = @klass || @inferer
        JSONAPI::Serializable::ResourceBuilder.build(@objects,
                                                     @exposures,
                                                     toplevel_inferer)
      end

      def namespace_inferer
        return nil unless @namespace
        proc do |klass|
          names = klass.name.split('::')
          klass = names.pop
          [@namespace, names, "Serializable#{klass}"].reject(&:nil?).join('::')
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

      def jsonapi_params
        @options
      end

      def jsonapi_errors
        @errors
      end
    end
  end
end
