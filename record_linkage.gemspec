lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'record_linkage'

Gem::Specification.new do |s|
  s.name     = 'record_linkage'
  s.version  = RecordLinkage::VERSION
  s.required_ruby_version = '>= 1.9.3'

  s.authors  = 'Brian Underwood'
  s.email    = 'public@brian-underwood.codes'
  s.homepage = 'https://github.com/cheerfulstoic/record_linkage'
  s.summary = <<SUMMARY
A library to do record linkage
SUMMARY

  s.license = 'MIT'

  s.description = <<DESCRIPTION
A library to do record linkage

Comparing objects to determine which are the same
DESCRIPTION

  s.require_path = 'lib'
  s.files = Dir.glob('{bin,lib,config}/**/*') +
    %w(README.md Gemfile record_linkage.gemspec)
  s.has_rdoc = true
  s.extra_rdoc_files = %w( README.md )
  s.rdoc_options = [
    '--quiet',
    '--title',
    '--line-numbers',
    '--main',
    'README.rdoc',
    '--inline-source']

  s.add_dependency('fuzzy-string-match')

  s.add_development_dependency('pry')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('guard')
  s.add_development_dependency('guard-rubocop')
  s.add_development_dependency('rubocop')
end
