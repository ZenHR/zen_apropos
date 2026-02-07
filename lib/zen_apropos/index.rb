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

      cache_mtime = File.mtime(cache_path)
      source.scan.none? { |file| File.mtime(file) > cache_mtime }
    end

    def read_cache
      Marshal.load(File.binread(cache_path))
    rescue StandardError
      build_and_cache
    end

    def build_and_cache
      all_entries = source.entries

      FileUtils.mkdir_p(File.dirname(cache_path))
      File.binwrite(cache_path, Marshal.dump(all_entries))

      all_entries
    end

    def cache_path
      File.join(source.root_path, CACHE_PATH)
    end
  end
end
