# frozen_string_literal: true

require "pastel"
require "tty-prompt"

module TypeWeaver
  module CLI
    module Commands
      class YardDiffExtract
        def initialize(options)
          @options = options
          @pastel = Pastel.new
          @config = TypeWeaver.config
          @prompt = TTY::Prompt.new
        end

        def execute
          puts @pastel.cyan("Extracting YARD documentation changes...")
          
          files = if @options[:file]
                   [Pathname.new(@options[:file])]
                 else
                   get_modified_ruby_files
                 end
          
          if files.empty?
            puts @pastel.yellow("No modified Ruby files found")
            return
          end
          
          extractor = Yard::DiffExtractor.new
          extracted_count = 0
          
          files.each do |file|
            diff_file = extractor.extract(file, @config.yard_diffs_dir)
            
            if diff_file
              puts @pastel.green("✓ Extracted diff for #{file}")
              extracted_count += 1
              
              # Revert source file if requested
              if @options[:revert]
                if revert_file(file)
                  puts @pastel.green("  ✓ Reverted #{file} to original state")
                end
              end
            end
          end
          
          puts ""
          puts @pastel.green("✓ Extracted #{extracted_count} diff file(s)")
          puts "  Location: #{@config.yard_diffs_dir}"
        end

        private

        def get_modified_ruby_files
          require "open3"
          stdout, _stderr, status = Open3.capture3("git diff --name-only HEAD")
          return [] unless status.success?
          
          stdout.split("\n").select { |f| f.end_with?(".rb") }.map { |f| Pathname.new(f) }
        end

        def revert_file(file)
          require "open3"
          _stdout, _stderr, status = Open3.capture3("git checkout HEAD -- #{file}")
          status.success?
        end
      end
    end
  end
end
