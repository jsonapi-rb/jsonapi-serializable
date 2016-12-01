require 'jsonapi/serializable/relationship'

module JSONAPI
  module Serializable
    class Resource
      # Mixin to handle resource relationships.
      module Relationships
        def self.prepended(klass)
          super
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :relationship_blocks
            end
            self.relationship_blocks = {}
          end
        end

        def initialize(*)
          super
          @_relationships = self.class.relationship_blocks
                                .each_with_object({}) do |(k, v), h|
            h[k] = Relationship.new(@_exposures, &v)
          end
        end

        # @see JSONAPI::Serializable::Resource#as_jsonapi
        def as_jsonapi(fields: nil, include: [])
          super.tap do |hash|
            rels = requested_relationships(fields)
                   .each_with_object({}) do |(k, v), h|
              h[k] = v.as_jsonapi(include.include?(k))
            end
            hash[:relationships] = rels if rels.any?
          end
        end

        # @api private
        def requested_relationships(fields)
          @_relationships
            .select { |k, _| fields.nil? || fields.include?(k) }
        end

        # DSL methods for declaring relationships.
        module DSL
          def inherited(klass)
            super
            klass.relationship_blocks = relationship_blocks.dup
          end

          # Declare a relationship for this resource. The properties of the
          #   relationship are set by providing a block in which the DSL methods
          #   of +JSONAPI::Serializable::Relationship+ are called.
          # @see JSONAPI::Serializable::Relationship
          #
          # @param [Symbol] name The key of the relationship.
          #
          # @example
          #   relationship :posts do
          #     resources { @user.posts.map { |p| PostResource.new(post: p) } }
          #   end
          #
          # @example
          #   relationship :author do
          #     resources do
          #       @post.author && UserResource.new(user: @post.author)
          #     end
          #     data do
          #       { type: 'users', id: @post.author_id }
          #     end
          #     link(:self) do
          #       "http://api.example.com/posts/#{@post.id}/relationships/author"
          #     end
          #     link(:related) do
          #       "http://api.example.com/posts/#{@post.id}/author"
          #     end
          #     meta do
          #       { author_online: @post.author.online? }
          #     end
          #   end
          def relationship(name, options = {}, &block)
            rel_block = proc do
              data(options[:class]) { @object.public_send(name) }
              instance_eval(&block) unless block.nil?
            end
            relationship_blocks[name.to_sym] = rel_block
          end
          alias has_many   relationship
          alias has_one    relationship
          alias belongs_to relationship
        end
      end
    end
  end
end
