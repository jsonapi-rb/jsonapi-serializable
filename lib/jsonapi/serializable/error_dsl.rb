module JSONAPI
  module Serializable
    module ErrorDSL
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def id(value = nil, &block)
          @id_val = value
          @id_block = block
        end

        def status(value = nil, &block)
          @status_val = value
          @status_block = block
        end

        def code(value = nil, &block)
          @code_val = value
          @code_block = block
        end

        def title(value = nil, &block)
          @title_val = value
          @title_block = block
        end

        def detail(value = nil, &block)
          @detail_val = value
          @detail_block = block
        end

        def meta(value = nil, &block)
          @meta_val = value
          @meta_block = block
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
