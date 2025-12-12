# frozen_string_literal: true

require "pastel"

module TypeWeaver
  module CLI
    module Commands
      class YardGenerateDiff
        def initialize(options)
          @options = options
          @pastel = Pastel.new
          @config = TypeWeaver.config
        end

        def execute
          puts @pastel.cyan("Generating documentation diffs...")
          
          files = if @options[:file]
                   [Pathname.new(@options[:file])]
                 else
                   find_ruby_files
                 end
          
          generator = Yard::DiffGenerator.new
          generated_count = 0
          
          files.each do |file|
            diff_file = generator.generate(file, @config.yard_diffs_dir)
            
            if diff_file
              puts @pastel.green("✓ Generated diff for #{file}")
              generated_count += 1
            end
          end
          
          puts ""
          puts @pastel.green("✓ Generated #{generated_count} diff file(s)")
          puts "  Location: #{@config.yard_diffs_dir}"
        end

        private

        def find_ruby_files
          Dir.glob("**/*.rb").reject do |path|
            @config.exclude_paths.any? { |pattern| File.fnmatch(pattern, path) }
          end.map { |path| Pathname.new(path) }
        end
      end
    end
  end
end
