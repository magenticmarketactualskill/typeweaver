# frozen_string_literal: true

require "yard"
require "diffy"

module TypeWeaver
  module Yard
    class DiffGenerator
      def generate(file_path, output_dir)
        YARD::Registry.clear
        YARD.parse(file_path.to_s)
        
        # Find undocumented methods
        undocumented = find_undocumented_methods
        
        return nil if undocumented.empty?
        
        # Generate documentation suggestions
        original_content = File.read(file_path)
        suggested_content = add_documentation(original_content, undocumented)
        
        # Create diff
        diff = Diffy::Diff.new(original_content, suggested_content, context: 3)
        
        # Save diff file
        FileUtils.mkdir_p(output_dir)
        diff_file_name = ".filediff__#{File.basename(file_path)}"
        diff_path = File.join(output_dir, diff_file_name)
        
        File.write(diff_path, diff.to_s(:unified))
        
        diff_path
      end

      private

      def find_undocumented_methods
        YARD::Registry.all(:method).select do |method|
          method.docstring.empty? || method.tags(:param).empty?
        end
      end

      def add_documentation(content, methods)
        # This is a simplified implementation
        # In production, would need to parse AST and insert docs at correct locations
        lines = content.split("\n")
        
        methods.each do |method|
          # Find method definition line
          method_line_index = lines.find_index do |line|
            line.match?(/def\s+#{Regexp.escape(method.name.to_s)}/)
          end
          
          next unless method_line_index
          
          # Generate YARD documentation
          doc_lines = generate_yard_doc(method)
          
          # Insert before method definition
          lines.insert(method_line_index, *doc_lines)
        end
        
        lines.join("\n")
      end

      def generate_yard_doc(method)
        lines = []
        lines << "  # TODO: Add method description"
        
        method.parameters.each do |param_name, _default|
          lines << "  # @param #{param_name} [Object] TODO: Add parameter description"
        end
        
        lines << "  # @return [Object] TODO: Add return value description"
        lines
      end
    end
  end
end
