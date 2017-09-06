require 'jsonapi/renderer'
require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Serializable
    class Renderer
      def initialize(renderer = JSONAPI::Renderer.new)
        @renderer = renderer
      end

      # Serialize resources into a JSON API document.
      #
      # @param resources [nil,Object,Array]
      # @param options [Hash] @see JSONAPI.render
      # @option class [Hash{Symbol=>String}] A map specifying for each type
      #   the corresponding serializable resource class name.
      # @option expose [Hash] The exposures made available in serializable
      #   resource class instances as instance variables.
      # @return [Hash]
      #
      # @example
      #   renderer.render(nil)
      #   # => { data: nil }
      #
      # @example
      #   renderer.render(user, class: { User: 'SerializableUser' })
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
      #   renderer.render([user1, user2], class: { User: 'SerializableUser' })
      #   # => { data: [{ type: 'users', id: 'foo', ... }, ...] }
      def render(resources, options = {})
        options   = options.dup
        klass     = options.delete(:class)
        exposures = options.delete(:expose) || {}
        resource_builder = JSONAPI::Serializable::ResourceBuilder.new(klass)
        exposures = exposures.merge(_resource_builder: resource_builder)

        resources = resource_builder.build(resources, exposures)

        @renderer.render(options.merge(data: resources))
      end

      # Serialize errors into a JSON API document.
      #
      # @param errors [Array]
      # @param options [Hash] @see JSONAPI.render
      # @option klass [Hash{Symbol=>String}] A map specifying for each type
      #   the corresponding serializable resource class name.
      # @option expose [Hash] The exposures made available in serializable
      #   error class instances as instance variables.
      # @return [Hash]
      #
      # @example
      #   error = JSONAPI::Serializable::Error.create(id: 'foo', title: 'bar')
      #   renderer.render([error])
      #   # => { errors: [{ id: 'foo', title: 'bar' }] }
      def render_errors(errors, options = {})
        options = options.dup
        klass   = options.delete(:klass)
        exposures = options.delete(:expose) || {}
        resource_builder = JSONAPI::Serializable::ResourceBuilder.new(klass)

        errors = errors.flat_map { |e| resource_builder.build(e, exposures) }

        @renderer.render(options.merge(errors: errors))
      end
    end
  end
end
