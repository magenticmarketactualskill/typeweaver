# frozen_string_literal: true

require "open3"
require "tempfile"

module TypeWeaver
  module Yard
    class DiffApplier
      def apply(diff_file_path)
        unless File.exist?(diff_file_path)
          warn "Diff file not found: #{diff_file_path}"
          return false
        end
        
        # Extract target file from diff
        target_file = extract_target_file(diff_file_path)
        
        unless target_file
          warn "Could not determine target file from diff"
          return false
        end
        
        # Apply the diff using patch command
        _stdout, stderr, status = Open3.capture3("patch #{target_file} < #{diff_file_path}")
        
        unless status.success?
          warn "Failed to apply diff: #{stderr}"
          return false
        end
        
        true
      end

      private

      def extract_target_file(diff_file_path)
        diff_content = File.read(diff_file_path)
        
        # Look for +++ line which indicates the target file
        match = diff_content.match(/^\+\+\+ (.+)$/)
        return nil unless match
        
        # Remove b/ prefix if present (git diff format)
        file_path = match[1].sub(%r{^b/}, "")
        file_path
      end
    end
  end
end
