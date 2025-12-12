# frozen_string_literal: true

module TypeWeaver
  module IR
    class IntermediateRepresentation
      attr_reader :modules, :classes

      def initialize
        @modules = []
        @classes = []
      end

      def add_module(mod)
        @modules << mod
      end

      def add_class(klass)
        @classes << klass
      end

      def find_class(name)
        @classes.find { |c| c.name == name }
      end

      def find_module(name)
        @modules.find { |m| m.name == name }
      end

      def all_nodes
        @modules + @classes
      end
    end
  end
end
