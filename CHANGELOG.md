# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-12

### Added

- Initial release of TypeWeaver
- Type signature generation in RBI and RBS formats
- Static analysis generator using Parser gem
- YARD documentation parser for type extraction
- Rails introspection for ActiveRecord models
- Non-destructive YARD documentation management
- `yard:diff-status` command to check if git changes are YARD-only
- `yard:diff-extract` command to extract YARD changes to diff files
- `yard:generate-diff` command to generate documentation suggestions
- `yard:preview-diff` command to preview diff files
- `yard:apply-diff` command to apply diff files
- `.yard_doc` status files with coverage metrics
- Comprehensive CLI with Thor
- RSpec unit tests
- Cucumber feature tests
- Project configuration via `.typeweaver/config.json`

### Documentation

- Complete README with usage examples
- Requirements document
- Workflow diagrams
- Technical specification

[0.1.0]: https://github.com/typeweaver/typeweaver/releases/tag/v0.1.0
