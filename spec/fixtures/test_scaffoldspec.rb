Scaffoldhub::Specification.new do |s|
  s.base_url        'http://github.com/patshaughnessy/scaffolds/default'
  s.erb_file        :src => 'templates/index3.html.erb', :dest => ''
  s.controller_file :src => 'templates/index2.html.erb', :dest => ''
  s.other_file      :src => 'templates/index.html.erb',  :dest => 'app/views/welcome'
end

# Yaml hash of scaffold options
#
#--- 
#:base_url: http://github.com/patshaughnessy/scaffolds/default
#:files: 
#- :src: templates/index.html.erb
#  :dest: app/views/welcome
#  :type: other
#- :src: templates/index2.html.erb
#  :dest: 
#  :type: controller
#- :src: templates/index3.html.erb
#  :dest: 
#  :type: erb
