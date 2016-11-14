module JSONAPI
  module Serializable
    module RelationshipDSL
      # Declare/access the data for this relationship.
      #
      # @yieldreturn [JSONAPI::Serializable::Resource,
      #               Array<JSONAPI::Serializable::Resource>,
      #               nil] The data for this relationship.
      #
      # @example
      #   data do
      #     @user.posts.map { |p| PostResource.new(post: p) }
      #   end
      #
      # @example
      #   data do
      #     @user.author && UserResource.new(user: @user.author)
      #   end
      # TODO(beauby): Update comments to take resource_class into account.
      def data(resource_class = nil)
        if block_given?
          # NOTE(beauby): Lazify computation since it is only needed when
          #   the corresponding relationship is included.
          @_data_block = proc do
            data = yield
            resources = _resources_for(resource_class, data)

            data.respond_to?(:each) ? resources : resources.first
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

      def _resources_for(resource_class, data)
        arr = Array(data)
        return arr if arr.first.nil? || arr.first.respond_to?(:as_jsonapi)

        arr.map { |model| _resource_for(resource_class, model) }
      end

      def _resource_for(resource_class, model)
        klass = resource_class || @_resource_inferer.call(model.class.name)

        klass.new(@_param_hash.merge(model: model))
      end
    end
  end
end
