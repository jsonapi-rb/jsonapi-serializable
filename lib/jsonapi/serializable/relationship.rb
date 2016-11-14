require 'jsonapi/serializable/link'
require 'jsonapi/serializable/relationship_dsl'

module JSONAPI
  module Serializable
    class Relationship
      include RelationshipDSL

      def initialize(param_hash = {}, &block)
        param_hash.each { |k, v| instance_variable_set("@#{k}", v) }
        @_param_hash = param_hash
        @_links = {}
        instance_eval(&block)
      end

      def as_jsonapi(included)
        hash = {}
        hash[:links] = @_links if @_links.any?
        hash[:meta] = @_meta unless @_meta.nil?
        return hash unless included || (!@_links.any? && @_meta.nil?)
        hash[:data] = linkage_data

        hash
      end

      private

      def linkage_data
        linkage_data = Array(data).map do |res|
          { type: res.jsonapi_type, id: res.jsonapi_id }
        end

        data.respond_to?(:each) ? linkage_data : linkage_data.first
      end
    end
  end
end
