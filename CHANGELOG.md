# Changelog

## 0.3.0

### Bug Fixes

- **Fixed `--changed-only` diffing against wrong files in CI.** The linter hardcoded `HEAD~1` as the diff base, which in Jenkins PreBuildMerge environments resolved to the PR branch tip — causing the linter to check files from master instead of PR changes.

### New Features

- **`--base REF` flag for the linter.** Allows specifying the git ref to diff against (e.g., `--base origin/master` for CI, `--base --staged` for pre-commit hooks). Defaults to `HEAD~1` for backward compatibility.

## 0.2.0

### Breaking Changes

- **Default tag renamed from `@zen` to `@zen_desc`.** Rename your annotations or set `config.tag = 'zen'` to keep the old prefix.

### Improvements

- `zen_desc` DSL now uses a pending-consumption pattern instead of a description-keyed registry, preventing collisions when two tasks share the same description
- Index cache no longer deserializes the cache file twice on cache hits
- Cache writing gracefully handles permission errors instead of raising

## 0.1.0

- Initial release
- CLI search with free text and structured filters (`team:`, `safety:`, `namespace:`, `keyword:`)
- `# @zen_desc` comment annotations and `zen_desc` DSL
- Interactive result viewer with source inspection
- Plain mode (`--plain`) for machine-readable output
- Annotation linter with `--changed-only` support
- Configurable tag prefix via `ZenApropos.configure`
- Custom glob patterns for monorepo support
- Mtime-based index caching
