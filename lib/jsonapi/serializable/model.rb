require 'jsonapi/serializable/model_dsl'
require 'jsonapi/serializable/resource'

module JSONAPI
  module Serializable
    class Model < Resource
      include ModelDSL

      class << self
        attr_accessor :api_version_val
      end

      def self.inherited(klass)
        super
        klass.api_version_val = api_version_val
      end

      id { @model.public_send(:id).to_s }

      def resource_klass_for(model_klass)
        names = model_klass.name.split('::'.freeze)
        model_klass_name = names.pop
        namespace = names.join('::'.freeze)
        version = self.class.api_version_val

        klass_name = [namespace, version, "Serializable#{model_klass_name}"]
                     .reject(&:nil?)
                     .reject(&:empty?)
                     .join('::'.freeze)

        Object.const_get(klass_name)
      end

      def nil?
        @model.nil?
      end

      def as_jsonapi(params = {})
        return nil if nil?
        super(params)
      end
    end
  end
end
