# frozen_string_literal: true

require "yaml"
require "yard"

module TypeWeaver
  module Yard
    class StatusGenerator
      def generate_status(file_path)
        YARD::Registry.clear
        YARD.parse(file_path.to_s)
        
        methods = collect_methods
        
        DocumentationStatus.new(
          file_path: file_path.to_s,
          methods: methods
        )
      end

      private

      def collect_methods
        all_methods = YARD::Registry.all(:method)
        
        all_methods.map do |yard_method|
          {
            name: yard_method.name.to_s,
            documented: documented?(yard_method),
            params_documented: params_documented?(yard_method),
            return_documented: return_documented?(yard_method),
            tags: yard_method.tags.map { |t| t.tag_name }
          }
        end
      end

      def documented?(yard_method)
        yard_method.docstring && !yard_method.docstring.empty?
      end

      def params_documented?(yard_method)
        param_tags = yard_method.tags(:param)
        return true if yard_method.parameters.empty?
        
        yard_method.parameters.all? do |param_name, _default|
          param_tags.any? { |tag| tag.name == param_name.to_s }
        end
      end

      def return_documented?(yard_method)
        yard_method.tag(:return) != nil
      end
    end

    class DocumentationStatus
      attr_reader :file_path, :methods

      def initialize(file_path:, methods:)
        @file_path = file_path
        @methods = methods
        @generated_at = Time.now
      end

      def total_methods
        @methods.size
      end

      def documented_methods
        @methods.count { |m| m[:documented] }
      end

      def coverage
        return 0 if total_methods.zero?
        (documented_methods.to_f / total_methods * 100).round(1)
      end

      def save(output_dir)
        FileUtils.mkdir_p(output_dir)
        
        # Convert file path to status file name
        status_file_name = @file_path.gsub("/", "__") + ".yard_doc"
        status_path = File.join(output_dir, status_file_name)
        
        data = {
          "file" => @file_path,
          "generated_at" => @generated_at.iso8601,
          "documentation_coverage" => coverage,
          "methods" => @methods,
          "statistics" => {
            "total_methods" => total_methods,
            "documented_methods" => documented_methods
          }
        }
        
        File.write(status_path, YAML.dump(data))
      end
    end
  end
end
