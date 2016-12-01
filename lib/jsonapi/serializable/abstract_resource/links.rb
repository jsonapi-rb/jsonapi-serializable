require 'jsonapi/serializable/link'

module JSONAPI
  module Serializable
    class AbstractResource
      module Links
        def self.prepended(klass)
          super
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :link_blocks
            end
            self.link_blocks = {}
          end
        end

        def initialize(*)
          super
          @_links = self.class.link_blocks.each_with_object({}) do |(k, v), h|
            h[k] = Link.as_jsonapi(@_exposures, &v)
          end
        end

        def as_jsonapi(*)
          super.tap do |hash|
            hash[:links] = @_links if @_links.any?
          end
        end

        module DSL
          def inherited(klass)
            super
            klass.link_blocks = link_blocks.dup
          end

          # Declare a link for this resource. The properties of the link are set
          #   by providing a block in which the DSL methods of
          #   +JSONAPI::Serializable::Link+ are called, or the value of the link
          #   is returned directly.
          # @see JSONAPI::Serialiable::Link
          #
          # @param [Symbol] name The key of the link.
          # @yieldreturn [Hash, String, nil] The block to compute the value, if
          #   any.
          #
          # @example
          #   link(:self) do
          #     "http://api.example.com/users/#{@user.id}"
          #   end
          #
          # @example
          #    link(:self) do
          #      href "http://api.example.com/users/#{@user.id}"
          #      meta is_self: true
          #    end
          def link(name, &block)
            link_blocks[name] = block
          end
        end
      end
    end
  end
end
