# frozen_string_literal: true

module TypeWeaver
  module Generators
    class RailsIntrospector < BaseGenerator
      def generate(file_path, ir)
        # Check if this is a Rails model
        return unless rails_model?(file_path)
        
        # Load the model class
        class_name = derive_class_name(file_path)
        
        begin
          require file_path.to_s
          model_class = Object.const_get(class_name)
          
          process_model(model_class, ir)
        rescue NameError, LoadError => e
          warn "Could not load Rails model #{class_name}: #{e.message}"
        end
      end

      private

      def rails_model?(file_path)
        file_path.to_s.include?("app/models/")
      end

      def derive_class_name(file_path)
        # app/models/user.rb => User
        # app/models/admin/post.rb => Admin::Post
        relative_path = file_path.to_s.sub(%r{.*app/models/}, "").sub(/\.rb$/, "")
        relative_path.split("/").map(&:camelize).join("::")
      end

      def process_model(model_class, ir)
        return unless defined?(ActiveRecord::Base)
        return unless model_class < ActiveRecord::Base
        
        klass = IR::ClassNode.new(
          model_class.name,
          superclass: "ApplicationRecord"
        )
        
        # Add column methods
        model_class.columns.each do |column|
          add_column_methods(klass, column)
        end
        
        # Add association methods
        process_associations(klass, model_class)
        
        ir.add_class(klass)
      end

      def add_column_methods(klass, column)
        type = map_column_type(column.type)
        
        # Getter
        getter = IR::MethodNode.new(column.name)
        getter.set_return_type(IR::TypeNode.new(type, nullable: column.null))
        klass.add_method(getter)
        
        # Setter
        setter = IR::MethodNode.new("#{column.name}=")
        param = IR::ParameterNode.new("value", type: IR::TypeNode.new(type))
        setter.add_parameter(param)
        klass.add_method(setter)
      end

      def process_associations(klass, model_class)
        # belongs_to
        model_class.reflect_on_all_associations(:belongs_to).each do |assoc|
          method = IR::MethodNode.new(assoc.name.to_s)
          method.set_return_type(IR::TypeNode.new(assoc.class_name, nullable: true))
          klass.add_method(method)
        end
        
        # has_many
        model_class.reflect_on_all_associations(:has_many).each do |assoc|
          method = IR::MethodNode.new(assoc.name.to_s)
          collection_type = IR::TypeNode.new("ActiveRecord::Associations::CollectionProxy")
          method.set_return_type(collection_type)
          klass.add_method(method)
        end
      end

      def map_column_type(db_type)
        case db_type
        when :string, :text then "String"
        when :integer, :bigint then "Integer"
        when :float, :decimal then "Float"
        when :boolean then "TrueClass | FalseClass"
        when :datetime, :timestamp then "Time"
        when :date then "Date"
        when :json, :jsonb then "Hash"
        else "Object"
        end
      end
    end
  end
end
