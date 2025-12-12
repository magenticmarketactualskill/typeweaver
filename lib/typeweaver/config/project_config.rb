# frozen_string_literal: true

require "json"
require "pathname"

module TypeWeaver
  module Config
    class ProjectConfig
      DEFAULT_CONFIG = {
        "version" => "1.0.0",
        "output_formats" => ["rbi", "rbs"],
        "generation_sources" => ["static", "yard", "rails"],
        "exclude_paths" => ["vendor/**", "tmp/**", "node_modules/**"],
        "rails" => {
          "enabled" => true,
          "components" => ["models", "routes", "controllers"]
        }
      }.freeze

      attr_reader :data

      def initialize(data = {})
        @data = DEFAULT_CONFIG.merge(data)
      end

      def self.load(path = nil)
        path ||= TypeWeaver.config_dir.join("config.json")
        
        if File.exist?(path)
          data = JSON.parse(File.read(path))
          new(data)
        else
          new
        end
      end

      def save(path = nil)
        path ||= TypeWeaver.config_dir.join("config.json")
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(@data))
      end

      def output_formats
        @data["output_formats"]
      end

      def generation_sources
        @data["generation_sources"]
      end

      def exclude_paths
        @data["exclude_paths"]
      end

      def rails_enabled?
        @data.dig("rails", "enabled")
      end

      def rails_components
        @data.dig("rails", "components") || []
      end

      def types_dir
        TypeWeaver.config_dir.join("types")
      end

      def rbi_dir
        types_dir.join("rbi")
      end

      def rbs_dir
        types_dir.join("rbs")
      end

      def yard_status_dir
        TypeWeaver.config_dir.join("yard_status")
      end

      def yard_diffs_dir
        TypeWeaver.config_dir.join("yard_diffs")
      end
    end
  end
end
