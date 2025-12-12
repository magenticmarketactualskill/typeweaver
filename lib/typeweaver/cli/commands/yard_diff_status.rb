# frozen_string_literal: true

require "pastel"
require "open3"

module TypeWeaver
  module CLI
    module Commands
      class YardDiffStatus
        def initialize(options)
          @options = options
          @pastel = Pastel.new
        end

        def execute
          puts @pastel.cyan("Checking git changes for YARD documentation...")
          
          # Get list of modified Ruby files
          modified_files = get_modified_ruby_files
          
          if modified_files.empty?
            puts @pastel.yellow("No modified Ruby files found")
            exit 0
          end
          
          # Check each file
          yard_only_files = []
          mixed_files = []
          
          modified_files.each do |file|
            if yard_only_changes?(file)
              yard_only_files << file
            else
              mixed_files << file
            end
          end
          
          # Display results
          display_results(yard_only_files, mixed_files)
          
          # Exit with appropriate code
          exit(mixed_files.empty? ? 0 : 1)
        end

        private

        def get_modified_ruby_files
          stdout, _stderr, status = Open3.capture3("git diff --name-only HEAD")
          return [] unless status.success?
          
          stdout.split("\n").select { |f| f.end_with?(".rb") }
        end

        def yard_only_changes?(file)
          stdout, _stderr, status = Open3.capture3("git diff HEAD -- #{file}")
          return false unless status.success?
          
          # Parse the diff and check if changes are only in comment lines
          lines = stdout.split("\n")
          change_lines = lines.select { |line| line.start_with?("+", "-") && !line.start_with?("+++", "---") }
          
          # All changed lines should be comments (start with # after whitespace)
          change_lines.all? do |line|
            content = line[1..-1] # Remove +/- prefix
            content.strip.start_with?("#") || content.strip.empty?
          end
        end

        def display_results(yard_only_files, mixed_files)
          puts ""
          
          if yard_only_files.any?
            puts @pastel.green("✓ YARD documentation only changes:")
            yard_only_files.each do |file|
              puts "  #{file}"
            end
          end
          
          if mixed_files.any?
            puts ""
            puts @pastel.red("✗ Mixed changes (code + documentation):")
            mixed_files.each do |file|
              puts "  #{file}"
            end
          end
          
          puts ""
          if mixed_files.empty?
            puts @pastel.green("✓ All changes in #{yard_only_files.size} file(s) are YARD documentation only")
          else
            puts @pastel.red("✗ #{mixed_files.size} file(s) contain implementation changes")
          end
        end
      end
    end
  end
end
