require 'jsonapi/serializable/link'
require 'jsonapi/serializable/error_dsl'

module JSONAPI
  module Serializable
    class ErrorSource
      def self.as_jsonapi(params = {})
        self.class.new(params).as_jsonapi
      end

      def initialize(params = {})
        params.each { |k, v| instance_variable_set("@#{k}", v) }
        @_data = {}
      end

      def as_jsonapi
        @_data
      end

      private

      def method_missing(name, arg)
        @_data[name] = arg
      end
    end

    class Error
      include ErrorDSL

      class << self
        attr_accessor :id, :id_block, :status, :status_block, :code,
                      :code_block, :title, :title_block, :detail, :detail_block,
                      :meta, :meta_block, :source_block, :link_blocks
      end

      self.link_blocks = {}

      def self.inherited(klass)
        super
        klass.link_blocks = self.class.link_blocks.dup
      end

      def initialize(exposures = {})
        @_exposures = exposures
        exposures.each { |k, v| instance_variable_set("@#{k}", v) }
      end

      def as_jsonapi
        hash = links.any? ? { links: links } : {}
        [:id, :status, :code, :title, :detail, :meta, :source]
          .each_with_object(hash) do |key, h|
          value = send(key)
          h[key] = value unless value.nil?
        end
      end

      private

      def links
        @_links ||= self.class.link_blocks.each_with_object({}) do |(k, v), h|
          h[k] = Link.as_jsonapi(@_exposures, v)
        end
      end

      def source
        @_source ||= ErrorSource.as_jsonapi(@_exposures,
                                            self.class.source_block)
      end

      [:id, :status, :code, :title, :detail, :meta].each do |key|
        define_method(key) do
          unless instance_variable_defined?("@#{key}")
            value = self.class.send(key) ||
                    instance_eval(self.class.send("#{key}_block"))
            instance_variable_set("@#{key}", value)
          end
          instance_variable_get("@#{key}")
        end
      end
    end
  end
end
