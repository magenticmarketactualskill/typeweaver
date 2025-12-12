# frozen_string_literal: true

require "pastel"

module TypeWeaver
  module CLI
    module Commands
      class Generate
        def initialize(options)
          @options = options
          @pastel = Pastel.new
          @config = TypeWeaver.config
        end

        def execute
          puts @pastel.cyan("Generating type signatures...")
          
          # Determine which sources to use
          sources = if @options[:source]
                     [@options[:source]]
                   else
                     @config.generation_sources
                   end
          
          # Determine which files to process
          files = if @options[:file]
                   [Pathname.new(@options[:file])]
                 else
                   find_ruby_files
                 end
          
          # Generate IR from sources
          ir = IR::IntermediateRepresentation.new
          
          sources.each do |source|
            generator = create_generator(source)
            files.each do |file|
              puts "  Processing #{file}..."
              generator.generate(file, ir)
            end
          end
          
          # Serialize to output formats
          @config.output_formats.each do |format|
            serializer = create_serializer(format)
            output_dir = format == "rbi" ? @config.rbi_dir : @config.rbs_dir
            
            serializer.serialize(ir, output_dir)
            puts @pastel.green("✓ Generated #{format.upcase} files in #{output_dir}")
          end
          
          puts @pastel.green("\n✓ Type generation complete!")
        end

        private

        def find_ruby_files
          Dir.glob("**/*.rb").reject do |path|
            @config.exclude_paths.any? { |pattern| File.fnmatch(pattern, path) }
          end.map { |path| Pathname.new(path) }
        end

        def create_generator(source)
          case source
          when "static"
            Generators::StaticAnalyzer.new
          when "yard"
            Generators::YardParser.new
          when "rails"
            Generators::RailsIntrospector.new
          else
            raise Error, "Unknown generation source: #{source}"
          end
        end

        def create_serializer(format)
          case format
          when "rbi"
            Serializers::RbiSerializer.new
          when "rbs"
            Serializers::RbsSerializer.new
          else
            raise Error, "Unknown output format: #{format}"
          end
        end
      end
    end
  end
end
