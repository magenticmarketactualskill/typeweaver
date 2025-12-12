# TypeWeaver

TypeWeaver is a Ruby gem that unifies type signature generation and YARD documentation management. It generates type signatures in both Sorbet RBI and RBS formats while providing sophisticated tools for managing YARD documentation through a non-destructive, diff-based workflow.

## Features

- **Dual Type System Support**: Generate both RBI (Sorbet) and RBS type signatures
- **Multiple Generation Sources**: Static analysis, YARD documentation, and Rails introspection
- **Non-Destructive Documentation Management**: Manage YARD docs through diffs, never automatically modifying source files
- **AI-Friendly Workflow**: Edit docs directly, then extract as diffs for review
- **Documentation Coverage Tracking**: Detailed `.yard_doc` status files for each Ruby file
- **Rails Support**: Automatic type generation for ActiveRecord models, routes, and controllers

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'typeweaver'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install typeweaver
```

## Quick Start

### 1. Initialize TypeWeaver

```bash
cd your-ruby-project
typeweaver init
```

This creates a `.typeweaver` directory with default configuration.

### 2. Generate Type Signatures

```bash
typeweaver generate
```

This generates RBI and RBS files in `.typeweaver/types/`.

### 3. Check Documentation Coverage

```bash
typeweaver yard:status
```

## Usage

### Type Generation

```bash
# Generate types from all sources
typeweaver generate

# Generate from specific source
typeweaver generate --source=static
typeweaver generate --source=yard
typeweaver generate --source=rails

# Generate for specific file
typeweaver generate --file=app/models/user.rb
```

### YARD Documentation Management

#### Check Documentation Status

```bash
# Project-wide status
typeweaver yard:status

# Specific file
typeweaver yard:status --file=app/models/user.rb
```

#### AI-Assisted Documentation Workflow

```bash
# 1. Edit YARD docs directly in source files (manually or with AI)
vim app/models/user.rb

# 2. Verify changes are YARD-only
typeweaver yard:diff-status

# 3. Extract changes to diff files
typeweaver yard:diff-extract --revert

# 4. Review the diff
typeweaver yard:preview-diff .typeweaver/yard_diffs/.filediff__user.rb

# 5. Apply after approval
typeweaver yard:apply-diff .typeweaver/yard_diffs/.filediff__user.rb
```

#### Generate Documentation Suggestions

```bash
# Generate diffs for undocumented methods
typeweaver yard:generate-diff

# Preview suggestions
typeweaver yard:preview-diff .typeweaver/yard_diffs/.filediff__user.rb

# Apply suggestions
typeweaver yard:apply-diff .typeweaver/yard_diffs/.filediff__user.rb
```

## Configuration

Edit `.typeweaver/config.json`:

```json
{
  "version": "1.0.0",
  "output_formats": ["rbi", "rbs"],
  "generation_sources": ["static", "yard", "rails"],
  "exclude_paths": ["vendor/**", "tmp/**", "node_modules/**"],
  "rails": {
    "enabled": true,
    "components": ["models", "routes", "controllers"]
  }
}
```

## File Structure

```
.typeweaver/
├── config.json              # Configuration
├── types/
│   ├── rbi/                 # Sorbet RBI files
│   └── rbs/                 # RBS files
├── yard_status/             # Documentation status (.yard_doc files)
└── yard_diffs/              # Documentation diffs (.filediff__* files)
```

## Commands

| Command | Description |
|---------|-------------|
| `typeweaver init` | Initialize TypeWeaver in current project |
| `typeweaver generate` | Generate type signatures |
| `typeweaver yard:status` | Show documentation coverage |
| `typeweaver yard:generate-diff` | Generate documentation suggestions |
| `typeweaver yard:diff-status` | Check if git changes are YARD-only |
| `typeweaver yard:diff-extract` | Extract YARD changes to diff files |
| `typeweaver yard:preview-diff` | Preview a diff file |
| `typeweaver yard:apply-diff` | Apply a diff file |
| `typeweaver version` | Show TypeWeaver version |

## Development

After checking out the repo, run:

```bash
bundle install
```

Run tests:

```bash
# RSpec unit tests
bundle exec rspec

# Cucumber feature tests
bundle exec cucumber
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/typeweaver/typeweaver.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
