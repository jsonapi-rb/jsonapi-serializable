require 'jsonapi/serializable/link'
require 'jsonapi/serializable/relationship'
require 'jsonapi/serializable/abstract_resource_dsl'

module JSONAPI
  module Serializable
    class AbstractResource
      include AbstractResourceDSL

      class << self
        attr_accessor :id_block,
                      :type_val, :type_block,
                      :meta_val, :meta_block,
                      :attribute_blocks,
                      :relationship_blocks,
                      :link_blocks
      end

      self.attribute_blocks    = {}
      self.relationship_blocks = {}
      self.link_blocks         = {}

      def self.inherited(klass)
        super
        klass.type_val            = type_val
        klass.type_block          = type_block
        klass.id_block            = id_block
        klass.meta_val            = meta_val
        klass.meta_block          = meta_block
        klass.attribute_blocks    = attribute_blocks.dup
        klass.relationship_blocks = relationship_blocks.dup
        klass.link_blocks         = link_blocks.dup
      end

      def initialize(exposures = {})
        exposures.each { |k, v| instance_variable_set("@#{k}", v) }
        @_exposures     = exposures
        @_type          = _type
        @_id            = _id
        @_attributes    = {}
        @_relationships = _relationships
        @_meta          = _meta
        @_links         = _links
      end

      def as_jsonapi(fields: nil, include: [])
        {}.tap do |hash|
          hash[:id]    = @_id
          hash[:type]  = @_type
          hash[:links] = @_links if @_links.any?
          hash[:meta]  = @_meta  unless @_meta.nil?

          attrs = requested_attributes(fields)
          hash[:attributes] = attrs if attrs.any?

          rels = requested_relationships(fields, include)
          hash[:relationships] = rels if rels.any?
        end
      end

      def jsonapi_type
        @_type
      end

      def jsonapi_id
        @_id
      end

      def jsonapi_related(include)
        @_relationships
          .select { |k, _| include.include?(k) }
          .each_with_object({}) { |(k, v), h| h[k] = v.related_resources }
      end

      private

      def _type
        self.class.type_val || instance_eval(&self.class.type_block)
      end

      def _id
        instance_eval(&self.class.id_block)
      end

      def _relationships
        self.class.relationship_blocks
            .each_with_object({}) do |(k, v), h|
          h[k] = Relationship.new(@_exposures, &v)
        end
      end

      def _meta
        if self.class.meta_block
          instance_eval(&self.class.meta_block)
        else
          self.class.meta_val
        end
      end

      def _links
        self.class.link_blocks
            .each_with_object({}) do |(k, v), h|
          h[k] = Link.as_jsonapi(@_exposures, &v)
        end
      end

      def requested_attributes(fields)
        self.class.attribute_blocks
            .select { |k, _| fields.nil? || fields.include?(k) }
            .each_with_object({}) { |(k, v), h| h[k] = instance_eval(&v) }
      end

      def requested_relationships(fields, include)
        @_relationships
          .select { |k, _| fields.nil? || fields.include?(k) }
          .each_with_object({}) do |(k, v), h|
          h[k] = v.as_jsonapi(include.include?(k))
        end
      end
    end
  end
end
