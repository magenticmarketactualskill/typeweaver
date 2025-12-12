# frozen_string_literal: true

module TypeWeaver
  module Serializers
    class RbsSerializer < BaseSerializer
      def serialize(ir, output_dir)
        ir.all_nodes.each do |node|
          content = serialize_node(node)
          file_path = File.join(output_dir, "#{node.name.downcase}.rbs")
          write_file(file_path, content)
        end
      end

      private

      def serialize_node(node)
        case node
        when IR::ClassNode
          serialize_class(node)
        when IR::ModuleNode
          serialize_module(node)
        end
      end

      def serialize_class(klass)
        lines = []
        
        if klass.namespace
          lines << "module #{klass.namespace}"
          lines << indent(serialize_class_body(klass), 1)
          lines << "end"
        else
          lines << serialize_class_body(klass)
        end
        
        lines.join("\n") + "\n"
      end

      def serialize_class_body(klass)
        lines = []
        superclass_part = klass.superclass ? " < #{klass.superclass}" : ""
        lines << "class #{klass.name}#{superclass_part}"
        
        klass.methods.each do |method|
          lines << indent(serialize_method(method), 1)
        end
        
        lines << "end"
        lines.join("\n")
      end

      def serialize_module(mod)
        lines = []
        lines << "module #{mod.full_name}"
        
        mod.methods.each do |method|
          lines << indent(serialize_method(method), 1)
        end
        
        lines << "end"
        lines.join("\n") + "\n"
      end

      def serialize_method(method)
        prefix = method.class_method? ? "self." : ""
        
        # Build parameter list
        params = method.parameters.map do |param|
          type_str = param.type ? param.type.to_rbs : "untyped"
          
          case param.kind
          when :required
            "#{type_str} #{param.name}"
          when :optional
            "?#{type_str} #{param.name}"
          when :keyword
            "#{param.name}: #{type_str}"
          when :keyword_optional
            "?#{param.name}: #{type_str}"
          when :rest
            "*#{type_str} #{param.name}"
          when :keyword_rest
            "**#{type_str} #{param.name}"
          when :block
            "{ () -> void } #{param.name}"
          end
        end.join(", ")
        
        # Return type
        return_type = method.return_type ? method.return_type.to_rbs : "void"
        
        "def #{prefix}#{method.name}: (#{params}) -> #{return_type}"
      end

      def indent(text, level)
        indent_str = "  " * level
        text.split("\n").map { |line| "#{indent_str}#{line}" }.join("\n")
      end
    end
  end
end
