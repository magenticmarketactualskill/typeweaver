# frozen_string_literal: true

module TypeWeaver
  module IR
    class ModuleNode
      attr_reader :name, :methods, :constants, :namespace

      def initialize(name, namespace: nil)
        @name = name
        @namespace = namespace
        @methods = []
        @constants = []
      end

      def add_method(method)
        @methods << method
      end

      def add_constant(constant)
        @constants << constant
      end

      def full_name
        namespace ? "#{namespace}::#{name}" : name
      end
    end
  end
end
