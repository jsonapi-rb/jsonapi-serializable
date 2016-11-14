require 'jsonapi/serializable/model_dsl'
require 'jsonapi/serializable/resource'

module JSONAPI
  module Serializable
    class Model < Resource
      include ModelDSL

      DEFAULT_RESOURCE_INFERER = lambda do |model_klass_name|
        names = model_klass_name.split('::'.freeze)
        klass_name = names.pop
        namespace = names.join('::'.freeze)

        klass_name = [namespace, "Serializable#{klass_name}"]
                     .reject(&:nil?)
                     .reject(&:empty?)
                     .join('::'.freeze)

        Object.const_get(klass_name)
      end

      id { @model.public_send(:id).to_s }

      def initialize(param_hash = {})
        param_hash[:_resource_inferer] ||= DEFAULT_RESOURCE_INFERER
        super(param_hash)
      end

      def nil?
        @model.nil?
      end
    end
  end
end
