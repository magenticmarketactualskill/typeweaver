# frozen_string_literal: true

module TypeWeaver
  module Serializers
    class RbiSerializer < BaseSerializer
      def serialize(ir, output_dir)
        ir.all_nodes.each do |node|
          content = serialize_node(node)
          file_path = File.join(output_dir, "#{node.name.downcase}.rbi")
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
        lines << "# typed: strong"
        lines << ""
        
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
        lines << "# typed: strong"
        lines << ""
        lines << "module #{mod.full_name}"
        
        mod.methods.each do |method|
          lines << indent(serialize_method(method), 1)
        end
        
        lines << "end"
        lines.join("\n") + "\n"
      end

      def serialize_method(method)
        lines = []
        
        # Build signature
        sig_parts = []
        
        # Parameters
        if method.parameters.any?
          params_str = method.parameters.map do |param|
            type_str = param.type ? param.type.to_rbi : "T.untyped"
            "#{param.name}: #{type_str}"
          end.join(", ")
          sig_parts << "params(#{params_str})"
        end
        
        # Return type
        return_type = method.return_type ? method.return_type.to_rbi : "void"
        sig_parts << "returns(#{return_type})"
        
        lines << "sig { #{sig_parts.join('.')} }"
        
        # Method definition
        prefix = method.class_method? ? "self." : ""
        params = method.parameters.map(&:name).join(", ")
        lines << "def #{prefix}#{method.name}(#{params}); end"
        
        lines.join("\n")
      end

      def indent(text, level)
        indent_str = "  " * level
        text.split("\n").map { |line| "#{indent_str}#{line}" }.join("\n")
      end
    end
  end
end
