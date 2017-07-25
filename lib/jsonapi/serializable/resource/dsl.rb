module JSONAPI
  module Serializable
    class Resource
      module DSL
        def self.extended(klass)
          class << klass
            attr_accessor :id_block, :type_val, :type_block, :attribute_blocks,
                          :relationship_blocks, :relationship_options,
                          :link_blocks, :meta_val, :meta_block
          end

          klass.attribute_blocks = {}
          klass.relationship_blocks  = {}
          klass.relationship_options = {}
          klass.link_blocks = {}
        end

        # rubocop:disable Metrics/AbcSize
        def inherited(klass)
          klass.id_block   = id_block
          klass.type_val   = type_val
          klass.type_block = type_block
          klass.attribute_blocks     = attribute_blocks.dup
          klass.relationship_blocks  = relationship_blocks.dup
          klass.relationship_options = relationship_options.dup
          klass.link_blocks = link_blocks.dup
          klass.meta_val    = meta_val
          klass.meta_block  = meta_block
        end
        # rubocop:enable Metrics/AbcSize

        # Declare the JSON API id of this resource.
        #
        # @yieldreturn [String] The id of the resource.
        #
        # @example
        #   id { @object.id.to_s }
        def id(&block)
          self.id_block = block
        end

        # @overload type(value)
        #   Declare the JSON API type of this resource.
        #   @param [String] value The value of the type.
        #
        #   @example
        #     type 'users'
        #
        # @overload type(&block)
        #   Declare the JSON API type of this resource.
        #   @yieldreturn [String] The value of the type.
        #
        #   @example
        #     type { @object.type }
        def type(value = nil, &block)
          self.type_val   = value.to_sym if value
          self.type_block = block
        end

        # Declare an attribute for this resource.
        #
        # @param [Symbol] name The key of the attribute.
        # @yieldreturn [Hash, String, nil] The block to compute the value.
        #
        # @example
        #   attribute(:name) { @object.name }
        def attribute(name, _options = {}, &block)
          block ||= proc { @object.public_send(name) }
          attribute_blocks[name.to_sym] = block
        end

        # Declare a list of attributes for this resource.
        #
        # @param [Array] *args The attributes keys.
        #
        # @example
        #   attributes :title, :body, :date
        def attributes(*args)
          args.each do |attr|
            attribute(attr)
          end
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
        #     "http://api.example.com/users/#{@object.id}"
        #   end
        #
        # @example
        #    link(:self) do
        #      href "http://api.example.com/users/#{@object.id}"
        #      meta is_self: true
        #    end
        def link(name, &block)
          link_blocks[name] = block
        end

        # @overload meta(value)
        #   Declare the meta information for this resource.
        #   @param [Hash] value The meta information hash.
        #
        #   @example
        #     meta key: value
        #
        # @overload meta(&block)
        #   Declare the meta information for this resource.
        #   @yieldreturn [String] The meta information hash.
        #   @example
        #     meta do
        #       { key: value }
        #     end
        def meta(value = nil, &block)
          self.meta_val = value
          self.meta_block = block
        end

        # Declare a relationship for this resource. The properties of the
        #   relationship are set by providing a block in which the DSL methods
        #   of +JSONAPI::Serializable::Relationship+ are called.
        # @see JSONAPI::Serializable::Relationship
        #
        # @param [Symbol] name The key of the relationship.
        # @param [Hash] options The options for the relationship.
        #
        # @example
        #   relationship :author do
        #     data do
        #       @object.author
        #     end
        #     linkage do
        #       { type: 'users', id: @object.author_id }
        #     end
        #     link(:self) do
        #       "http://api.example.com/posts/#{@object.id}/relationships/author"
        #     end
        #     link(:related) do
        #       "http://api.example.com/posts/#{@object.id}/author"
        #     end
        #     meta do
        #       { author_online: @object.author.online? }
        #     end
        #   end
        def relationship(name, options = {}, &block)
          rel_block = proc do
            data { @object.public_send(name) }
            instance_eval(&block) unless block.nil?
          end
          relationship_blocks[name.to_sym]  = rel_block
          relationship_options[name.to_sym] = options
        end

        alias has_many   relationship
        alias has_one    relationship
        alias belongs_to relationship
      end
    end
  end
end
