# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'scaffold_hub'

Gem::Specification.new do |s|
  s.name        = "scaffold_hub"
  s.version     = ScaffoldHub::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pat Shaughnessy']
  s.email       = ['pat@patshaughnessy.net']
  s.homepage    = "http://github.com/patshaughnessy/scaffold_hub"
  s.summary     = %q{A gallery of variations on Rails scaffolding}
  s.description = %q{A gallery of variations on Rails scaffolding}

  s.rubyforge_project = "scaffold_hub"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency             'rails'

  s.add_development_dependency 'rake',          '~> 0.8.7'
  s.add_development_dependency 'rspec',         '~> 2.3.0'
  s.add_development_dependency 'mocha',         '~> 0.9.10'
end
