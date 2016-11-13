require 'jsonapi/serializable/model_dsl'
require 'jsonapi/serializable/resource'

module JSONAPI
  module Serializable
    class Model < Resource
      include ModelDSL

      id { @model.public_send(:id).to_s }

      def self.resource_klass_for(model_klass_name)
        names = model_klass_name.split('::'.freeze)
        klass_name = names.pop
        namespace = names.join('::'.freeze)

        klass_name = [namespace, "Serializable#{klass_name}"]
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
