# frozen_string_literal: true

module TypeWeaver
  module IR
    class MethodNode
      attr_reader :name, :parameters, :return_type, :visibility, :class_method

      def initialize(name, class_method: false, visibility: :public)
        @name = name
        @class_method = class_method
        @visibility = visibility
        @parameters = []
        @return_type = nil
      end

      def add_parameter(parameter)
        @parameters << parameter
      end

      def set_return_type(type)
        @return_type = type
      end

      def class_method?
        @class_method
      end

      def instance_method?
        !@class_method
      end
    end
  end
end
