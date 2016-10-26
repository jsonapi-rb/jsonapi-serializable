module JSONAPI
  module Serializable
    class Link
      def self.as_jsonapi(param_hash = {}, &block)
        new(param_hash, &block).as_jsonapi
      end

      def initialize(param_hash = {}, &block)
        param_hash.each { |k, v| instance_variable_set("@#{k}", v) }
        static_value = instance_eval(&block)
        if static_value.is_a?(Hash)
          @_hash = static_value
        elsif static_value.is_a?(String)
          @_href = static_value
        end
      end

      # @overload href(value)
      #   Declare the href for this link.
      #   @param [String] value The value of href.
      #
      #   @example
      #     href "http://api.example.com/users/#{@user.id}"
      #
      # @overload href(&block)
      #   Declare the href for this link.
      #   @yieldreturn [String] The value of href.
      #
      #   @example
      #     href do
      #       "http://api.example.com/users/#{@user.id}"
      #     end
      def href(value = nil, &block)
        @_href = block.nil? ? value : instance_eval(&block)
      end

      # @overload meta(value)
      #   Declare the meta information for this link.
      #   @param [Hash] value The meta information hash.
      #
      #   @example
      #     meta paginated: true
      #
      # @overload meta(&block)
      #   Declare the meta information for this link.
      #   @yieldreturn [String] The meta information hash.
      #   @example
      #     meta do
      #       { paginated: true }
      #     end
      def meta(value = nil, &block)
        @_meta = block.nil? ? value : instance_eval(&block)
      end

      def as_jsonapi
        @_hash ||=
          if @_meta.nil?
            @_href
          else
            { href: @_href, meta: @_meta }
          end
      end
    end
  end
end
