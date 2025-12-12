# frozen_string_literal: true

require "open3"
require "diffy"

module TypeWeaver
  module Yard
    class DiffExtractor
      def extract(file_path, output_dir)
        # Get git diff for the file
        stdout, _stderr, status = Open3.capture3("git diff HEAD -- #{file_path}")
        
        return nil unless status.success?
        return nil if stdout.empty?
        
        # Parse diff and extract only YARD comment changes
        yard_diff = extract_yard_changes(stdout)
        
        return nil if yard_diff.empty?
        
        # Save diff file
        FileUtils.mkdir_p(output_dir)
        diff_file_name = ".filediff__#{File.basename(file_path)}"
        diff_path = File.join(output_dir, diff_file_name)
        
        File.write(diff_path, yard_diff)
        
        diff_path
      end

      private

      def extract_yard_changes(full_diff)
        # Parse the diff and keep only changes to comment lines
        lines = full_diff.split("\n")
        
        # Keep header lines and comment changes
        filtered_lines = []
        in_hunk = false
        
        lines.each do |line|
          if line.start_with?("+++", "---", "@@")
            filtered_lines << line
            in_hunk = true if line.start_with?("@@")
          elsif in_hunk && (line.start_with?("+", "-") || line.start_with?(" "))
            # Keep if it's a comment line or context
            content = line[1..-1] || ""
            if content.strip.start_with?("#") || content.strip.empty? || line.start_with?(" ")
              filtered_lines << line
            end
          end
        end
        
        filtered_lines.join("\n")
      end
    end
  end
end
