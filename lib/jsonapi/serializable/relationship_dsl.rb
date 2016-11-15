require 'jsonapi/serializable/resource_builder'

module JSONAPI
  module Serializable
    module RelationshipDSL
      # Declare the data for this relationship.
      # @param [String,Constant,Hash{Symbol=>String,Constant}] resource_class
      # @yieldreturn The data for this relationship.
      #   If it is nil, an object implementing the Serializable::Resource
      #   interface, an empty array, or an array of objects implementing the
      #   Serializable::Resource interface, then it is used as is.
      #   Otherwise an appropriate Serializable::Model subclass is inferred
      #   from the object(s)' namespace/class, the resource_class parameter if
      #   provided, and the @_resource_inferer.
      #
      # @example
      #   data do
      #     @user.posts.map { |p| PostResource.new(post: p) }
      #   end
      #
      # @example
      #   data do
      #     @post.author && UserResource.new(user: @user.author)
      #   end
      #
      # @example
      #   data do
      #     @user.posts
      #   end
      # end
      #
      # @example
      #   data SerializablePost do
      #     @user.posts
      #   end
      #
      # @example
      #   data "SerializableUser" do
      #     @post.author
      #   end
      def data(resource_class = nil)
        if block_given?
          # NOTE(beauby): Lazify computation since it is only needed when
          #   the corresponding relationship is included.
          @_data_block = proc do
            _resources_for(yield, resource_class)
          end
        else
          # NOTE(beauby): In the case of a computation heavy relationship with
          #   nil value, this block might be executed multiple times.
          @_data ||= @_data_block.call
        end
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
        @_links[name] = Link.as_jsonapi(@_param_hash, &block)
      end

      private

      # @api private
      def _resources_for(models, resource_class)
        resource_class ||= @_resource_inferer

        ResourceBuilder.build(models, @_param_hash, resource_class)
      end
    end
  end
end
