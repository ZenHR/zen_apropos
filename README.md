# zen_apropos

[![Gem Version](https://badge.fury.io/rb/zen_apropos.svg)](https://badge.fury.io/rb/zen_apropos)

Apropos-style search engine for rake tasks.

`zen_apropos` scans your `.rake` files, indexes task names, descriptions, source code, and structured annotations, then lets you search across all of them from the command line or Rails console.

## Installation

Add to your Gemfile:

```ruby
gem 'zen_apropos'
```

Or install directly:

```bash
gem install zen_apropos
```

Then run `bundle install`.

## CLI Usage

### Search

```bash
zen_apropos <query>          # interactive rich output
zen_apropos <query> --plain  # machine-readable, no colors
```

In rich mode, results are numbered. You can type a number to view the full source of that task, enter a new query to search again, or `q` to quit.

Plain mode outputs pipe-separated columns (`name | description | safety | team`) suitable for piping to other tools.

### Lint

```bash
zen_apropos lint                 # check all rake files
zen_apropos lint --changed-only  # only files changed in the current branch
```

The linter checks that every `desc`/`task` pair has annotation tags or uses `zen_desc`. Exits with code `0` when all tasks are annotated, `1` when any are missing.

Output looks like:

```
⚠ lib/tasks/new_feature.rake:12 -- task "new_feature:run" has no @zen annotations

2 task(s) missing annotations. Consider adding @zen tags or using zen_desc.
```

### Help

```bash
zen_apropos --help
```

## Query Syntax

Free text matches against task name, description, keywords, and source code (case-insensitive substring match). You can also use structured filters:

| Filter | Example | Matches |
|--------|---------|---------|
| `team:` | `team:search` | Tasks owned by the "search" team |
| `safety:` | `safety:destructive` | Tasks marked as destructive |
| `namespace:` | `namespace:indexer` | Tasks in the `indexer` namespace |
| `keyword:` | `keyword:elasticsearch` | Tasks tagged with that keyword |

Filters can be combined with each other and with free text. Multiple filters use implicit AND:

```bash
zen_apropos "employee team:search"
zen_apropos "team:finance safety:destructive"
zen_apropos "keyword:elasticsearch"
```

## Annotation System

Every rake task should be annotated with team ownership, safety level, and keywords. There are two equivalent ways to do this.

### Option A: Comment Tags

Place annotation lines immediately before the `desc` line. The default tag is `@zen`:

```ruby
namespace :indexer do
  # @zen team: search
  # @zen safety: safe
  # @zen keywords: elasticsearch, reindex
  desc 'Reindex all employees'
  task employees: :environment do
    Employee.reindex
  end
end
```

### Option B: `zen_desc` DSL

Replace `desc` with `zen_desc` and pass metadata as keyword arguments:

```ruby
zen_desc 'Run database backup',
  team: 'devops',
  safety: :safe,
  keywords: %w[backup database postgres]

task db_backup: :environment do
  system('pg_dump ...')
end
```

`zen_desc` calls `desc` under the hood, so `rake -T` keeps working.

**Note:** `zen_desc` is opt-in. You must explicitly require it:

```ruby
require 'zen_apropos/zen_desc'
```

### Supported Fields

| Field | Type | Values |
|-------|------|--------|
| `team` | String | Any team name (e.g. `search`, `hr-platform`, `devops`) |
| `safety` | String/Symbol | `safe`, `caution`, `destructive` |
| `keywords` | Array/CSV | Comma-separated in comment tags, `%w[]` array in `zen_desc` |

## Custom Tag Prefix

By default, zen_apropos recognizes `# @zen` comment tags. If you want a different prefix for your organization:

### Project setup (recommended)

Run `init` to generate a binstub with your tag pre-configured:

```bash
bundle exec zen_apropos init --tag myapp
```

This creates `bin/zen_apropos` in your project. From then on:

```bash
bin/zen_apropos "employee"        # uses @myapp automatically
bin/zen_apropos lint               # lints for @myapp tags
```

### Per-command flag

Pass `--tag` to any command:

```bash
zen_apropos --tag myapp "employee"
zen_apropos lint --tag myapp --changed-only
```

### Ruby configuration

In an initializer or setup file:

```ruby
ZenApropos.configure do |config|
  config.tag = 'myapp'
end
```

### Then annotate with your custom tag

```ruby
# @myapp team: payments
# @myapp safety: destructive
# @myapp keywords: refund, stripe
desc 'Process pending refunds'
task process_refunds: :environment do
  # ...
end
```

The linter, CLI, and console helper all respect the configured tag.

## Rails Console Integration

You can define an `apropos` helper for quick searching in the Rails console. Example initializer:

```ruby
# config/initializers/zen_apropos.rb
return unless Rails.env.development?

require 'zen_apropos'
require 'zen_apropos/zen_desc'

ZenApropos.configure do |config|
  config.tag = 'myapp' # recognizes # @myapp instead of # @zen
end

RAKE_PATHS = ['lib/tasks/**/*.rake'].freeze

def apropos(query = nil, plain: false)
  engine = ZenApropos::Engine.new(plain: plain, glob_patterns: RAKE_PATHS)

  if query.nil? || query.strip.empty?
    puts engine.help
    return
  end

  puts engine.search(query)
end
```

Then in the console:

```ruby
apropos "employee"
apropos "team:finance safety:destructive"
apropos "reindex", plain: true
apropos  # shows help
```

## Custom Glob Patterns

By default, zen_apropos scans `lib/tasks/**/*.rake`. For monorepos or apps with tasks in non-standard locations, pass custom patterns:

```ruby
engine = ZenApropos::Engine.new(
  glob_patterns: ['lib/tasks/**/*.rake', 'packages/**/lib/tasks/**/*.rake']
)
```

## Running Tests

```bash
bundle exec rake test
```

Or simply:

```bash
bundle exec rake
```

Tests use Minitest and run against fixture rake files in `test/fixtures/`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ZenHR/zen_apropos. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
