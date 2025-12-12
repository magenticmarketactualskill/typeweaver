# frozen_string_literal: true

module TypeWeaver
  module IR
    class TypeNode
      attr_reader :name, :generic_params, :nullable

      def initialize(name, generic_params: [], nullable: false)
        @name = name
        @generic_params = generic_params
        @nullable = nullable
      end

      def to_rbi
        type_str = if @generic_params.any?
                    "#{@name}[#{@generic_params.map(&:to_rbi).join(', ')}]"
                  else
                    @name
                  end
        
        @nullable ? "T.nilable(#{type_str})" : type_str
      end

      def to_rbs
        type_str = if @generic_params.any?
                    "#{@name}[#{@generic_params.map(&:to_rbs).join(', ')}]"
                  else
                    @name
                  end
        
        @nullable ? "#{type_str}?" : type_str
      end

      def self.from_string(type_string)
        # Simple type parsing - can be enhanced
        nullable = type_string.end_with?("?")
        name = nullable ? type_string[0..-2] : type_string
        
        new(name, nullable: nullable)
      end
    end
  end
end
