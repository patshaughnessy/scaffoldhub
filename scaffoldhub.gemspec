# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'scaffoldhub'

Gem::Specification.new do |s|
  s.name        = "scaffoldhub"
  s.version     = Scaffoldhub::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pat Shaughnessy']
  s.email       = ['pat@patshaughnessy.net']
  s.homepage    = "http://scaffoldhub.org"
  s.summary     = %q{Generate customized Rails scaffolding from scaffoldhub.org}
  s.description = %q{Run Rails scaffold generator with customized templates downloaded from scaffoldhub.org}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency             'rails'

  s.add_development_dependency 'rake',          '~> 0.8.7'
  s.add_development_dependency 'rspec',         '~> 2.3.0'
  s.add_development_dependency 'mocha',         '~> 0.9.10'
end
