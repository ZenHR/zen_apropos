# Changelog

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
