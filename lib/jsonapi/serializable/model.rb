require 'jsonapi/serializable/model_dsl'
require 'jsonapi/serializable/resource'

module JSONAPI
  module Serializable
    class Model < Resource
      include ModelDSL

      id { @model.public_send(:id).to_s }

      def nil?
        @model.nil?
      end
    end
  end
end
