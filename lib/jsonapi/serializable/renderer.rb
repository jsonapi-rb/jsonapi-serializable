require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Serializable
    class SuccessRenderer
      # Serialize resources into a JSON API document.
      #
      # @param [nil,Object,Array] resources
      # @param [Hash] options @see JSONAPI.render
      # @option [Class,Symbol,String,Hash{Symbol,String=>Class,Symbol,String}]
      #   class The serializable resource class(es) to use for the primary
      #   resources.
      # @option [String] namespace The namespace in which to look for
      #   serializable resource classes.
      # @option [#call] inferrer The callable used for inferring a serializable
      #   resource class name from a resource class name.
      # @option [Hash] expose The exposures made available in serializable
      #   resource class instances as instance variables.
      # @return [Hash]
      #
      # @example
      #   JSONAPI.serialize(nil)
      #   # => { data: nil }
      #
      # @example
      #   JSONAPI.serialize(user)
      #   # => {
      #          data: {
      #            type: 'users',
      #            id: 'foo',
      #            attributes: { ... },
      #            relationships: { ... }
      #          }
      #        }
      #
      # @example
      #   JSONAPI.serialize([user1, user2])
      #   # => { data: [{ type: 'users', id: 'foo', ... }, ...] }
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

    class ErrorsRenderer
      # Serialize errors into a JSON API document.
      #
      # @param [Array] errors
      # @param [Hash] options @see JSONAPI.render
      # @return [Hash]
      #
      # @example
      #   error = JSONAPI::Serializable::Error.create(id: 'foo', title: 'bar')
      #   JSONAPI.serialize_errors([error])
      #   # => { errors: [{ id: 'foo', title: 'bar' }] }
      def render(errors, options = {})
        JSONAPI.render(options.merge(errors: errors))
      end
    end
  end
end
