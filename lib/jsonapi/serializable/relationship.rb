require 'jsonapi/serializable/link'
require 'jsonapi/serializable/relationship_dsl'

module JSONAPI
  module Serializable
    class Relationship
      include RelationshipDSL

      def initialize(exposures = {}, &block)
        exposures.each { |k, v| instance_variable_set("@#{k}", v) }
        @_exposures = exposures
        @_links     = {}
        instance_eval(&block)
      end

      def as_jsonapi(included)
        {}.tap do |hash|
          hash[:links] = @_links if @_links.any?
          hash[:meta]  = @_meta  unless @_meta.nil?
          include_linkage = included || (!@_links.any? && @_meta.nil?)
          hash[:data] = linkage_data if include_linkage
        end
      end

      def related_resources
        return @_related_resources if @_related_resources

        resources = @_resources_block.call
        @_arity = resources.respond_to?(:each) ? :many : :one
        @_related_resources = Array(resources)

        @_related_resources
      end

      private

      def linkage_data
        return @_linkage_block.call if @_linkage_block

        linkage_data = related_resources.map do |res|
          { type: res.jsonapi_type, id: res.jsonapi_id }
        end

        @_arity == :many ? linkage_data : linkage_data.first
      end
    end
  end
end
