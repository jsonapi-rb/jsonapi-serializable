require 'jsonapi/serializable/link'
require 'jsonapi/serializable/relationship'
require 'jsonapi/serializable/resource_dsl'

module JSONAPI
  module Serializable
    class Resource
      include ResourceDSL

      class << self
        attr_accessor :type_val, :type_block, :id_block, :attribute_blocks,
                      :relationship_blocks, :link_blocks, :meta_val, :meta_block
      end

      self.attribute_blocks = {}
      self.relationship_blocks = {}
      self.link_blocks = {}

      def self.inherited(klass)
        super
        klass.type_val = type_val
        klass.type_block = type_block
        klass.id_block = id_block
        klass.meta_val = meta_val
        klass.meta_block = meta_block
        klass.attribute_blocks = attribute_blocks.dup
        klass.relationship_blocks = relationship_blocks.dup
        klass.link_blocks = link_blocks.dup
      end

      def initialize(exposures = {})
        @_exposures = exposures
        exposures.each { |k, v| instance_variable_set("@#{k}", v) }
      end

      def as_jsonapi(params = {})
        return nil if nil?

        {}.tap do |hash|
          hash[:id] = jsonapi_id
          hash[:type] = jsonapi_type
          requested_attrs = params[:fields] || self.class.attribute_blocks.keys
          attrs = attributes(requested_attrs)
          hash[:attributes] = attrs if attrs.any?
          requested_rels = params[:fields] ||
                           self.class.relationship_blocks.keys
          rels = relationships(requested_rels, params[:include] || [])
          hash[:relationships] = rels if rels.any?
          hash[:links] = links if links.any?
          hash[:meta] = meta unless meta.nil?
        end
      end

      def jsonapi_type
        @_type ||= self.class.type_val || instance_eval(&self.class.type_block)
      end

      def jsonapi_id
        @_id ||= instance_eval(&self.class.id_block)
      end

      def jsonapi_related(include)
        @_relationships
          .select { |k, _| include.include?(k) }
          .each_with_object({}) { |(k, v), h| h[k] = Array(v.data) }
      end

      private

      def attributes(fields)
        @_attributes ||= {}
        self.class.attribute_blocks
            .select { |k, _| !@_attributes.key?(k) && fields.include?(k) }
            .each { |k, v| @_attributes[k] = instance_eval(&v) }
        @_attributes.select { |k, _| fields.include?(k) }
      end

      def relationships(fields, include)
        @_relationships ||= self.class.relationship_blocks
                                .each_with_object({}) do |(k, v), h|
          h[k] = Relationship.new(@_exposures, &v)
        end
        @_relationships
          .select { |k, _| fields.include?(k) }
          .each_with_object({}) do |(k, v), h|
          h[k] = v.as_jsonapi(include.include?(k))
        end
      end

      def meta
        @_meta ||=
          if self.class.meta_val
            self.class.meta_val
          elsif self.class.meta_block
            instance_eval(&self.class.meta_block)
          end
      end

      def links
        @_links ||= self.class.link_blocks.each_with_object({}) do |(k, v), h|
          h[k] = Link.as_jsonapi(@_exposures, &v)
        end
      end
    end
  end
end
