# frozen_string_literal: true

require "pastel"
require "diffy"

module TypeWeaver
  module CLI
    module Commands
      class YardPreviewDiff
        def initialize(diff_file, options)
          @diff_file = diff_file
          @options = options
          @pastel = Pastel.new
        end

        def execute
          unless File.exist?(@diff_file)
            puts @pastel.red("✗ Diff file not found: #{@diff_file}")
            exit 1
          end
          
          puts @pastel.cyan("Previewing diff: #{@diff_file}")
          puts ""
          
          # Read and display the diff
          diff_content = File.read(@diff_file)
          
          # Use Diffy for colored output
          puts Diffy::Diff.new(diff_content, "", source: "strings", context: 3).to_s(:color)
          
          puts ""
          puts @pastel.yellow("Note: No files were modified. This is a preview only.")
        end
      end
    end
  end
end
