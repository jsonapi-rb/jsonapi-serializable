module JSONAPI
  module Serializable
    module ErrorDSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        [:id, :status, :code, :title, :detail, :meta].each do |key|
          define_method(key) do |*args, &block|
            send("@#{key}=", args[0])
            send("@#{key}_block=", block)
          end
        end

        def link(name, &block)
          link_blocks[name] = block
        end

        def source(&block)
          self.source_block = block
        end
      end
    end
  end
end
