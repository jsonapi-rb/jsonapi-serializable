require 'jsonapi/renderer'

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
      # @option class [Hash{Symbol=>Class}] A map specifying for each type
      #   the corresponding serializable resource class.
      # @option expose [Hash] The exposures made available in serializable
      #   resource class instances as instance variables.
      # @return [Hash]
      #
      # @example
      #   renderer.render(nil)
      #   # => { data: nil }
      #
      # @example
      #   renderer.render(user, class: { User: SerializableUser })
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
      #   renderer.render([user1, user2], class: { User: SerializableUser })
      #   # => { data: [{ type: 'users', id: 'foo', ... }, ...] }
      def render(resources, options = {})
        options   = options.dup
        klass     = options.delete(:class) || {}
        exposures = options.delete(:expose) || {}
        exposures = exposures.merge(_class: klass)

        resources =
          JSONAPI::Serializable.resources_for(resources, exposures, klass)

        @renderer.render(options.merge(data: resources))
      end

      # Serialize errors into a JSON API document.
      #
      # @param errors [Array]
      # @param options [Hash] @see JSONAPI.render
      # @option class [Hash{Symbol=>Class}] A map specifying for each type
      #   the corresponding serializable error class.
      # @option expose [Hash] The exposures made available in serializable
      #   error class instances as instance variables.
      # @return [Hash]
      #
      # @example
      #   error = JSONAPI::Serializable::Error.create(id: 'foo', title: 'bar')
      #   renderer.render([error])
      #   # => { errors: [{ id: 'foo', title: 'bar' }] }
      def render_errors(errors, options = {})
        options   = options.dup
        klass     = options.delete(:class) || {}
        exposures = options.delete(:expose) || {}

        errors =
          JSONAPI::Serializable.resources_for(errors, exposures, klass)

        @renderer.render(options.merge(errors: errors))
      end
    end
  end
end
