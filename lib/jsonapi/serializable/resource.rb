require 'jsonapi/serializable/abstract_resource'
require 'jsonapi/serializable/resource_dsl'

module JSONAPI
  module Serializable
    class Resource < AbstractResource
      include ResourceDSL

      id { @object.public_send(:id).to_s }
    end
  end
end
