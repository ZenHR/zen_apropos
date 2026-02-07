require 'fileutils'

# Builds and caches the search index with mtime-based invalidation
#
# Cache is stored in tmp/zen_apropos_index.cache
# Rebuilds automatically when any .rake file is newer than the cache
module ZenApropos
  class Index
    CACHE_PATH = 'tmp/zen_apropos_index.cache'.freeze

    attr_reader :source

    def initialize(source:)
      @source = source
    end

    def entries
      return read_cache if cache_fresh?

      build_and_cache
    end

    private

    def cache_fresh?
      return false unless File.exist?(cache_path)

      cached = Marshal.load(File.binread(cache_path))
      return false unless cached.is_a?(Hash) && cached[:glob_patterns] == source.glob_patterns

      cache_mtime = File.mtime(cache_path)
      source.scan.none? { |file| File.mtime(file) > cache_mtime }
    rescue StandardError
      false
    end

    def read_cache
      cached = Marshal.load(File.binread(cache_path))
      cached[:entries]
    rescue StandardError
      build_and_cache
    end

    def build_and_cache
      all_entries = source.entries

      FileUtils.mkdir_p(File.dirname(cache_path))
      File.binwrite(cache_path, Marshal.dump({ entries: all_entries, glob_patterns: source.glob_patterns }))

      all_entries
    end

    def cache_path
      File.join(source.root_path, CACHE_PATH)
    end
  end
end
