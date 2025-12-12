# frozen_string_literal: true

require_relative "typeweaver/version"
require_relative "typeweaver/config/project_config"
require_relative "typeweaver/ir/intermediate_representation"
require_relative "typeweaver/ir/module_node"
require_relative "typeweaver/ir/class_node"
require_relative "typeweaver/ir/method_node"
require_relative "typeweaver/ir/parameter_node"
require_relative "typeweaver/ir/type_node"
require_relative "typeweaver/generators/base_generator"
require_relative "typeweaver/generators/static_analyzer"
require_relative "typeweaver/generators/yard_parser"
require_relative "typeweaver/generators/rails_introspector"
require_relative "typeweaver/serializers/base_serializer"
require_relative "typeweaver/serializers/rbi_serializer"
require_relative "typeweaver/serializers/rbs_serializer"
require_relative "typeweaver/yard/status_generator"
require_relative "typeweaver/yard/diff_generator"
require_relative "typeweaver/yard/diff_extractor"
require_relative "typeweaver/yard/diff_applier"
require_relative "typeweaver/cli/main"

module TypeWeaver
  class Error < StandardError; end
  
  # Project root directory
  def self.root
    @root ||= Pathname.new(Dir.pwd)
  end
  
  # TypeWeaver configuration directory
  def self.config_dir
    @config_dir ||= root.join(".typeweaver")
  end
  
  # Load project configuration
  def self.config
    @config ||= Config::ProjectConfig.load
  end
  
  # Reset configuration (useful for testing)
  def self.reset!
    @root = nil
    @config_dir = nil
    @config = nil
  end
end
