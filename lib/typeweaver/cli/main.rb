# frozen_string_literal: true

require "thor"
require "pastel"
require "tty-prompt"

module TypeWeaver
  module CLI
    class Main < Thor
      def self.exit_on_failure?
        true
      end

      desc "version", "Display TypeWeaver version"
      def version
        puts "TypeWeaver #{TypeWeaver::VERSION}"
      end

      desc "init", "Initialize TypeWeaver in the current project"
      method_option :format, type: :string, default: "both", 
                    desc: "Output format: rbi, rbs, or both"
      def init
        pastel = Pastel.new
        
        puts pastel.cyan("Initializing TypeWeaver...")
        
        # Create directory structure
        config_dir = TypeWeaver.config_dir
        FileUtils.mkdir_p(config_dir)
        FileUtils.mkdir_p(config_dir.join("types", "rbi"))
        FileUtils.mkdir_p(config_dir.join("types", "rbs"))
        FileUtils.mkdir_p(config_dir.join("yard_status"))
        FileUtils.mkdir_p(config_dir.join("yard_diffs"))
        
        # Create default configuration
        config = Config::ProjectConfig.new
        
        # Set output format based on option
        case options[:format]
        when "rbi"
          config.data["output_formats"] = ["rbi"]
        when "rbs"
          config.data["output_formats"] = ["rbs"]
        else
          config.data["output_formats"] = ["rbi", "rbs"]
        end
        
        config.save
        
        puts pastel.green("✓ Created .typeweaver directory")
        puts pastel.green("✓ Created config.json")
        puts ""
        puts "Next steps:"
        puts "  1. Review .typeweaver/config.json"
        puts "  2. Run 'typeweaver generate' to generate type signatures"
        puts "  3. Run 'typeweaver yard:status' to check documentation coverage"
      end

      desc "generate", "Generate type signatures"
      method_option :source, type: :string, 
                    desc: "Generation source: static, yard, or rails"
      method_option :file, type: :string, 
                    desc: "Generate for a specific file"
      def generate
        require_relative "commands/generate"
        Commands::Generate.new(options).execute
      end

      desc "yard", "YARD documentation commands"
      subcommand "yard", Yard
    end

    class Yard < Thor
      desc "status", "Display documentation coverage status"
      method_option :file, type: :string, desc: "Check specific file"
      def status
        require_relative "commands/yard_status"
        Commands::YardStatus.new(options).execute
      end

      desc "generate-diff", "Generate documentation diffs for undocumented methods"
      method_option :file, type: :string, desc: "Generate diff for specific file"
      def generate_diff
        require_relative "commands/yard_generate_diff"
        Commands::YardGenerateDiff.new(options).execute
      end

      desc "diff-status", "Check if git changes are exclusively YARD documentation"
      def diff_status
        require_relative "commands/yard_diff_status"
        Commands::YardDiffStatus.new(options).execute
      end

      desc "diff-extract", "Extract YARD documentation changes from modified files"
      method_option :file, type: :string, desc: "Extract from specific file"
      method_option :revert, type: :boolean, default: false,
                    desc: "Revert source files after extraction"
      def diff_extract
        require_relative "commands/yard_diff_extract"
        Commands::YardDiffExtract.new(options).execute
      end

      desc "preview-diff DIFF_FILE", "Preview changes from a diff file"
      def preview_diff(diff_file)
        require_relative "commands/yard_preview_diff"
        Commands::YardPreviewDiff.new(diff_file, options).execute
      end

      desc "apply-diff DIFF_FILE", "Apply a diff file to source code"
      method_option :yes, type: :boolean, default: false,
                    desc: "Skip confirmation prompt"
      def apply_diff(diff_file)
        require_relative "commands/yard_apply_diff"
        Commands::YardApplyDiff.new(diff_file, options).execute
      end
    end
  end
end
