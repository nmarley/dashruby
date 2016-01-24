#encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)
require "dashruby/version"

Gem::Specification.new do |s|
  s.name              = "dashruby"
  s.version           = Dash::VERSION
  s.description       = "Dash toolkit for Ruby"
  s.summary           = "Rich library for building awesome Dash apps."
  s.authors           = ["Oleg Andreev", "Ryan Smith", "Nathan Marley"]
  s.homepage          = "https://github.com/nmarley/dashruby"
  s.rubyforge_project = "dashruby"
  s.license           = "MIT"
  s.require_paths     = ["lib"]
  s.add_runtime_dependency 'ffi', '~> 1.9', '>= 1.9.3'

  s.files = []
  s.files << "README.md"
  s.files << "RELEASE_NOTES.md"
  s.files << "LICENSE"
  s.files << Dir["{documentation}/**/*.md"]
  s.files << Dir["{lib,spec}/**/*.rb"]
  s.test_files = s.files.select {|path| path =~ /^spec\/.*_spec.rb/}
end
