# frozen_string_literal: true

require_relative "lib/typeweaver/version"

Gem::Specification.new do |spec|
  spec.name = "typeweaver"
  spec.version = TypeWeaver::VERSION
  spec.authors = ["TypeWeaver Team"]
  spec.email = ["typeweaver@example.com"]

  spec.summary = "Unified type signature generation and YARD documentation management for Ruby"
  spec.description = "TypeWeaver generates type signatures (RBI/RBS) from Ruby code and manages YARD documentation through a non-destructive diff-based workflow"
  spec.homepage = "https://github.com/typeweaver/typeweaver"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/typeweaver/typeweaver"
  spec.metadata["changelog_uri"] = "https://github.com/typeweaver/typeweaver/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*.rb
    exe/*
    LICENSE.txt
    README.md
    CHANGELOG.md
  ])
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "parser", "~> 3.3"
  spec.add_dependency "yard", "~> 0.9"
  spec.add_dependency "diffy", "~> 3.4"
  spec.add_dependency "tty-prompt", "~> 0.23"
  spec.add_dependency "tty-table", "~> 0.12"
  spec.add_dependency "pastel", "~> 0.8"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
