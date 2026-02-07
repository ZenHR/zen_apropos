require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'
require_relative '../lib/zen_apropos'

FIXTURES_PATH = File.expand_path('fixtures', __dir__)

def build_entry(name: 'test:task', namespace: '', description: '', file_path: '/app/test.rake',
                line_number: 1, source: '', team: nil, safety: nil, keywords: nil, args: [])
  ZenApropos::Entry.new(
    name:        name,
    namespace:   namespace,
    description: description,
    file_path:   file_path,
    line_number: line_number,
    source:      source,
    annotations: { team: team, safety: safety, keywords: keywords }.compact,
    args:        args
  )
end
