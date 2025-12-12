# frozen_string_literal: true

require "yard"

module TypeWeaver
  module Generators
    class YardParser < BaseGenerator
      def generate(file_path, ir)
        YARD::Registry.clear
        YARD.parse(file_path.to_s)
        
        YARD::Registry.all(:class).each do |yard_class|
          process_yard_class(yard_class, ir)
        end
        
        YARD::Registry.all(:module).each do |yard_module|
          process_yard_module(yard_module, ir)
        end
      end

      private

      def process_yard_class(yard_class, ir)
        klass = IR::ClassNode.new(
          yard_class.name.to_s,
          superclass: yard_class.superclass&.name&.to_s,
          namespace: yard_class.namespace&.name&.to_s
        )
        
        yard_class.meths.each do |yard_method|
          method = process_yard_method(yard_method)
          klass.add_method(method)
        end
        
        ir.add_class(klass)
      end

      def process_yard_module(yard_module, ir)
        mod = IR::ModuleNode.new(
          yard_module.name.to_s,
          namespace: yard_module.namespace&.name&.to_s
        )
        
        yard_module.meths.each do |yard_method|
          method = process_yard_method(yard_method)
          mod.add_method(method)
        end
        
        ir.add_module(mod)
      end

      def process_yard_method(yard_method)
        method = IR::MethodNode.new(
          yard_method.name.to_s,
          class_method: yard_method.scope == :class
        )
        
        # Extract parameter types from @param tags
        yard_method.tags(:param).each do |param_tag|
          type = param_tag.types ? IR::TypeNode.from_string(param_tag.types.first) : nil
          param = IR::ParameterNode.new(param_tag.name, type: type)
          method.add_parameter(param)
        end
        
        # Extract return type from @return tag
        return_tag = yard_method.tag(:return)
        if return_tag && return_tag.types
          return_type = IR::TypeNode.from_string(return_tag.types.first)
          method.set_return_type(return_type)
        end
        
        method
      end
    end
  end
end
