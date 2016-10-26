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
        hash[:data] = eval_linkage_data

        hash
      end

      private

      def eval_linkage_data
        @_linkage_data ||=
          if @_linkage_data_block
            @_linkage_data_block.call
          elsif data.respond_to?(:each)
            data.map { |res| { type: res.jsonapi_type, id: res.jsonapi_id } }
          elsif data.nil?
            nil
          else
            { type: data.jsonapi_type, id: data.jsonapi_id }
          end
      end
    end
  end
end
