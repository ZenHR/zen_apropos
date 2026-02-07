require_relative 'lib/zen_apropos/version'

Gem::Specification.new do |spec|
  spec.name     = 'zen_apropos'
  spec.version  = ZenApropos::VERSION
  spec.authors  = ['Ahmad Keewan', 'ZenHR Engineering']
  spec.email    = ['a.keewan@zenhr.com']
  spec.homepage = 'https://www.zenhr.com'
  spec.license  = 'MIT'

  spec.summary     = 'Apropos-style search engine for rake tasks'
  spec.description = <<~DESC
    ZenApropos indexes your rake tasks and lets you search across names, descriptions,
    source code, and structured annotations from the CLI or Rails console. Includes a
    linter to enforce annotation coverage and supports configurable tag prefixes.
  DESC

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ZenHR/zen_apropos'
  spec.metadata['changelog_uri']   = 'https://github.com/ZenHR/zen_apropos/blob/master/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) || f.end_with?('.gem') }
  end
  spec.bindir        = 'bin'
  spec.executables   = ['zen_apropos']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
end
