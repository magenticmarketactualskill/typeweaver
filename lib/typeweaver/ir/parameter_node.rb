# frozen_string_literal: true

module TypeWeaver
  module IR
    class ParameterNode
      attr_reader :name, :type, :kind, :default_value

      # kind can be: :required, :optional, :keyword, :keyword_optional, :rest, :keyword_rest, :block
      def initialize(name, type: nil, kind: :required, default_value: nil)
        @name = name
        @type = type
        @kind = kind
        @default_value = default_value
      end

      def required?
        @kind == :required
      end

      def optional?
        @kind == :optional || @kind == :keyword_optional
      end

      def keyword?
        @kind == :keyword || @kind == :keyword_optional
      end

      def rest?
        @kind == :rest || @kind == :keyword_rest
      end

      def block?
        @kind == :block
      end
    end
  end
end
