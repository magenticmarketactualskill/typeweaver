# frozen_string_literal: true

require "pastel"
require "tty-table"

module TypeWeaver
  module CLI
    module Commands
      class YardStatus
        def initialize(options)
          @options = options
          @pastel = Pastel.new
          @config = TypeWeaver.config
        end

        def execute
          puts @pastel.cyan("Analyzing YARD documentation coverage...")
          
          files = if @options[:file]
                   [Pathname.new(@options[:file])]
                 else
                   find_ruby_files
                 end
          
          generator = Yard::StatusGenerator.new
          results = []
          
          files.each do |file|
            status = generator.generate_status(file)
            results << status
            
            # Save .yard_doc file
            status.save(@config.yard_status_dir)
          end
          
          # Display summary
          display_summary(results)
        end

        private

        def find_ruby_files
          Dir.glob("**/*.rb").reject do |path|
            @config.exclude_paths.any? { |pattern| File.fnmatch(pattern, path) }
          end.map { |path| Pathname.new(path) }
        end

        def display_summary(results)
          total_methods = results.sum { |r| r.total_methods }
          documented_methods = results.sum { |r| r.documented_methods }
          coverage = total_methods.zero? ? 0 : (documented_methods.to_f / total_methods * 100).round(1)
          
          puts ""
          puts @pastel.bold("Documentation Coverage Summary")
          puts "=" * 50
          puts "Total files: #{results.size}"
          puts "Total methods: #{total_methods}"
          puts "Documented methods: #{documented_methods}"
          puts "Coverage: #{@pastel.bold(coverage.to_s + '%')}"
          puts ""
          
          # Show files with lowest coverage
          low_coverage = results.sort_by(&:coverage).take(5)
          
          if low_coverage.any?
            puts @pastel.bold("Files with lowest coverage:")
            table = TTY::Table.new(
              header: ["File", "Coverage", "Methods"],
              rows: low_coverage.map { |r| [r.file_path, "#{r.coverage}%", "#{r.documented_methods}/#{r.total_methods}"] }
            )
            puts table.render(:unicode)
          end
        end
      end
    end
  end
end
