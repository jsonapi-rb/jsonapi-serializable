module JSONAPI
  module Serializable
    class Relationship
      module DSL
        # Declare the related resources for this relationship.
        # @yieldreturn The related resources for this relationship.
        #
        # @example
        #   data do
        #     @object.posts
        #   end
        # end
        def data
          # NOTE(beauby): Lazify computation since it is only needed when
          #   the corresponding relationship is included.
          @_resources_block = proc do
            JSONAPI::Serializable.resources_for(yield, @_exposures, @_class)
          end
        end

        # @overload linkage(options = {}, &block)
        #   Explicitly declare linkage data.
        #   @yieldreturn The resource linkage.
        #
        #   @example
        #     linkage do
        #       @object.posts.map { |p| { id: p.id.to_s, type: 'posts' } }
        #     end
        #
        # @overload linkage(options = {})
        #   Forces standard linkage even if relationship not included.
        #
        #   @example
        #     linkage always: true
        def linkage(options = {}, &block)
          @_include_linkage = options.fetch(:always, false)
          @_linkage_block = block
        end

        # @overload meta(value)
        #   Declare the meta information for this relationship.
        #   @param [Hash] value The meta information hash.
        #
        #   @example
        #     meta paginated: true
        #
        # @overload meta(&block)
        #   Declare the meta information for this relationship.
        #   @yieldreturn [Hash] The meta information hash.
        #
        #   @example
        #     meta do
        #       { paginated: true }
        #     end
        def meta(value = nil)
          @_meta = value || yield
        end

        # Declare a link for this relationship. The properties of the link are set
        #   by providing a block in which the DSL methods of
        #   +JSONAPI::Serializable::Link+ are called.
        # @see JSONAPI::Serialiable::Link
        #
        # @param [Symbol] name The key of the link.
        # @yieldreturn [Hash, String, nil] The block to compute the value, if any.
        #
        # @example
        #   link(:self) do
        #     "http://api.example.com/users/#{@user.id}/relationships/posts"
        #   end
        #
        # @example
        #    link(:related) do
        #      href "http://api.example.com/users/#{@user.id}/posts"
        #      meta authorization_needed: true
        #    end
        def link(name, &block)
          @_links[name] = Link.as_jsonapi(@_exposures, &block)
        end
      end
    end
  end
end
