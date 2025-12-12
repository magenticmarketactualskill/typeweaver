# frozen_string_literal: true

require "pastel"
require "tty-prompt"

module TypeWeaver
  module CLI
    module Commands
      class YardApplyDiff
        def initialize(diff_file, options)
          @diff_file = diff_file
          @options = options
          @pastel = Pastel.new
          @prompt = TTY::Prompt.new
        end

        def execute
          unless File.exist?(@diff_file)
            puts @pastel.red("✗ Diff file not found: #{@diff_file}")
            exit 1
          end
          
          puts @pastel.cyan("Applying diff: #{@diff_file}")
          puts ""
          
          # Show the diff
          diff_content = File.read(@diff_file)
          puts diff_content
          puts ""
          
          # Confirm unless --yes flag
          unless @options[:yes]
            confirmed = @prompt.yes?("Apply this diff?")
            unless confirmed
              puts @pastel.yellow("Cancelled")
              return
            end
          end
          
          # Apply the diff
          applier = Yard::DiffApplier.new
          
          if applier.apply(@diff_file)
            puts @pastel.green("✓ Diff applied successfully")
            
            # Archive the diff file
            archive_diff(@diff_file)
          else
            puts @pastel.red("✗ Failed to apply diff")
            exit 1
          end
        end

        private

        def archive_diff(diff_file)
          archive_dir = File.join(File.dirname(diff_file), "applied")
          FileUtils.mkdir_p(archive_dir)
          
          archive_path = File.join(archive_dir, File.basename(diff_file))
          FileUtils.mv(diff_file, archive_path)
          
          puts @pastel.dim("  Archived to #{archive_path}")
        end
      end
    end
  end
end
