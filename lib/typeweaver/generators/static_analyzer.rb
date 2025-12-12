# frozen_string_literal: true

require "parser/current"

module TypeWeaver
  module Generators
    class StaticAnalyzer < BaseGenerator
      def generate(file_path, ir)
        source = read_file(file_path)
        ast = Parser::CurrentRuby.parse(source)
        
        return unless ast
        
        process_node(ast, ir)
      rescue Parser::SyntaxError => e
        warn "Syntax error in #{file_path}: #{e.message}"
      end

      private

      def process_node(node, ir, namespace: nil)
        return unless node.is_a?(Parser::AST::Node)

        case node.type
        when :module
          process_module(node, ir, namespace)
        when :class
          process_class(node, ir, namespace)
        when :def, :defs
          # Methods are processed within their class/module context
        else
          node.children.each { |child| process_node(child, ir, namespace: namespace) }
        end
      end

      def process_module(node, ir, namespace)
        module_name = extract_name(node.children[0])
        full_namespace = namespace ? "#{namespace}::#{module_name}" : module_name
        
        mod = IR::ModuleNode.new(module_name, namespace: namespace)
        
        # Process module body
        body = node.children[1]
        process_module_body(body, mod, full_namespace)
        
        ir.add_module(mod)
      end

      def process_class(node, ir, namespace)
        class_name = extract_name(node.children[0])
        superclass_node = node.children[1]
        superclass = superclass_node ? extract_name(superclass_node) : nil
        
        full_namespace = namespace ? "#{namespace}::#{class_name}" : class_name
        
        klass = IR::ClassNode.new(class_name, superclass: superclass, namespace: namespace)
        
        # Process class body
        body = node.children[2]
        process_class_body(body, klass, full_namespace)
        
        ir.add_class(klass)
      end

      def process_module_body(node, mod, namespace)
        return unless node

        if node.type == :begin
          node.children.each { |child| process_module_member(child, mod, namespace) }
        else
          process_module_member(node, mod, namespace)
        end
      end

      def process_class_body(node, klass, namespace)
        return unless node

        if node.type == :begin
          node.children.each { |child| process_class_member(child, klass, namespace) }
        else
          process_class_member(node, klass, namespace)
        end
      end

      def process_module_member(node, mod, namespace)
        return unless node.is_a?(Parser::AST::Node)

        case node.type
        when :def
          method = process_method(node, class_method: false)
          mod.add_method(method)
        when :defs
          method = process_method(node, class_method: true)
          mod.add_method(method)
        end
      end

      def process_class_member(node, klass, namespace)
        return unless node.is_a?(Parser::AST::Node)

        case node.type
        when :def
          method = process_method(node, class_method: false)
          klass.add_method(method)
        when :defs
          method = process_method(node, class_method: true)
          klass.add_method(method)
        end
      end

      def process_method(node, class_method:)
        if class_method
          # defs: (self, :method_name, args, body)
          method_name = node.children[1]
          args_node = node.children[2]
        else
          # def: (:method_name, args, body)
          method_name = node.children[0]
          args_node = node.children[1]
        end

        method = IR::MethodNode.new(method_name.to_s, class_method: class_method)
        
        # Process parameters
        process_parameters(args_node, method) if args_node
        
        method
      end

      def process_parameters(args_node, method)
        return unless args_node.is_a?(Parser::AST::Node)

        args_node.children.each do |arg|
          next unless arg.is_a?(Parser::AST::Node)

          param = case arg.type
                  when :arg
                    IR::ParameterNode.new(arg.children[0].to_s, kind: :required)
                  when :optarg
                    IR::ParameterNode.new(arg.children[0].to_s, kind: :optional)
                  when :kwarg
                    IR::ParameterNode.new(arg.children[0].to_s, kind: :keyword)
                  when :kwoptarg
                    IR::ParameterNode.new(arg.children[0].to_s, kind: :keyword_optional)
                  when :restarg
                    IR::ParameterNode.new(arg.children[0].to_s, kind: :rest)
                  when :kwrestarg
                    IR::ParameterNode.new(arg.children[0].to_s, kind: :keyword_rest)
                  when :blockarg
                    IR::ParameterNode.new(arg.children[0].to_s, kind: :block)
                  end

          method.add_parameter(param) if param
        end
      end

      def extract_name(node)
        return nil unless node

        case node.type
        when :const
          node.children[1].to_s
        when :send
          node.children[1].to_s
        else
          node.to_s
        end
      end
    end
  end
end
