require 'jsonapi/serializable/model_dsl'
require 'jsonapi/serializable/resource'

module JSONAPI
  module Serializable
    class Model < Resource
      include ModelDSL

      id { @model.public_send(:id).to_s }
    end
  end
end
