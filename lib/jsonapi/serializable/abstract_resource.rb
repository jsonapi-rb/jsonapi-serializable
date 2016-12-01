require 'jsonapi/serializable/abstract_resource/id'
require 'jsonapi/serializable/abstract_resource/type'
require 'jsonapi/serializable/abstract_resource/meta'
require 'jsonapi/serializable/abstract_resource/links'
require 'jsonapi/serializable/abstract_resource/attributes'
require 'jsonapi/serializable/abstract_resource/relationships'

module JSONAPI
  module Serializable
    class AbstractResource
      prepend Id
      prepend Type
      prepend Meta
      prepend Links
      prepend Attributes
      prepend Relationships

      def initialize(exposures = {})
        exposures.each { |k, v| instance_variable_set("@#{k}", v) }
        @_exposures = exposures
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
