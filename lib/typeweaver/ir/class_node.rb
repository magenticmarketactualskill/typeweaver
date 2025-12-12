# frozen_string_literal: true

module TypeWeaver
  module IR
    class ClassNode
      attr_reader :name, :superclass, :methods, :instance_variables, :namespace

      def initialize(name, superclass: nil, namespace: nil)
        @name = name
        @superclass = superclass
        @namespace = namespace
        @methods = []
        @instance_variables = []
      end

      def add_method(method)
        @methods << method
      end

      def add_instance_variable(name, type)
        @instance_variables << { name: name, type: type }
      end

      def full_name
        namespace ? "#{namespace}::#{name}" : name
      end
    end
  end
end
