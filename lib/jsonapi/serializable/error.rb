require 'jsonapi/serializable/link'
require 'jsonapi/serializable/error_dsl'

module JSONAPI
  module Serializable
    class ErrorSource
      def self.as_jsonapi(params = {}, &block)
        new(params, &block).as_jsonapi
      end

      def initialize(params = {}, &block)
        params.each { |k, v| instance_variable_set("@#{k}", v) }
        @_data = {}
        instance_eval(&block)
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
        attr_accessor :id_val, :id_block, :status_val, :status_block, :code_val,
                      :code_block, :title_val, :title_block, :detail_val,
                      :detail_block, :meta_val, :meta_block, :source_block,
                      :link_blocks
      end

      self.link_blocks = {}

      def self.inherited(klass)
        super
        klass.link_blocks = link_blocks.dup
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
          h[k] = Link.as_jsonapi(@_exposures, &v)
        end
      end

      def source
        return @_source if @_source
        return if self.class.source_block.nil?
        @_source = ErrorSource.as_jsonapi(@_exposures,
                                          &self.class.source_block)
      end

      [:id, :status, :code, :title, :detail, :meta].each do |key|
        define_method(key) do
          unless instance_variable_defined?("@_#{key}")
            block = self.class.send("#{key}_block")
            value =
              if block
                instance_eval(&block)
              else
                self.class.send("#{key}_val")
              end
            instance_variable_set("@_#{key}", value)
          end
          instance_variable_get("@_#{key}")
        end
      end
    end
  end
end
