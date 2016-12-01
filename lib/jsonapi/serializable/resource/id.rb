module JSONAPI
  module Serializable
    class Resource
      module Id
        def self.prepended(klass)
          super
          klass.class_eval do
            extend DSL
            class << self
              attr_accessor :id_block
            end
          end
        end

        def initialize(*)
          super
          @_id = instance_eval(&self.class.id_block).to_s
        end

        def as_jsonapi(*)
          super.tap do |hash|
            hash[:id] = @_id
          end
        end

        module DSL
          def inherited(klass)
            super
            klass.id_block = id_block
          end

          # Declare the JSON API id of this resource.
          #
          # @yieldreturn [String] The id of the resource.
          #
          # @example
          #   id { @user.id.to_s }
          def id(&block)
            self.id_block = block
          end
        end
      end
    end
  end
end
