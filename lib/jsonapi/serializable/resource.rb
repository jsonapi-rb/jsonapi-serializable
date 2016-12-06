require 'jsonapi/serializable/resource/id'
require 'jsonapi/serializable/resource/type'
require 'jsonapi/serializable/resource/meta'
require 'jsonapi/serializable/resource/links'
require 'jsonapi/serializable/resource/attributes'
require 'jsonapi/serializable/resource/relationships'

module JSONAPI
  module Serializable
    class Resource
      prepend Id
      prepend Type
      prepend Meta
      prepend Links
      prepend Attributes
      prepend Relationships

      # Default the value of id.
      id { @object.public_send(:id).to_s }

      def initialize(exposures = {})
        exposures.each { |k, v| instance_variable_set("@#{k}", v) }
        @_exposures = exposures
        @_exposures = { _resource_builder: ResourceBuilder.new }.merge!(@_exposures) unless @_exposures.key?(:_resource_builder)
      end

      def as_jsonapi(*)
        {}
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
    end
  end
end
