require 'yaml'
require '../lib/scaffoldhub/specification'
require ARGV[0]

open('scaffold_spec.yaml', 'wb') do |file|
  file.write(Scaffoldhub::Specification.to_yaml)
end
