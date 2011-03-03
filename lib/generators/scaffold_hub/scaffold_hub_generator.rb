#require 'rails/generators/rails/scaffold/scaffold_generator'

class ScaffoldHubGenerator < Rails::Generators::Base
  #source_root File.expand_path('../templates', __FILE__)

#  remove_hook_for :resource_controller
#  remove_class_option :actions
#  remove_hook_for :template_engine
#  hook_for :template_engine, :as => :scaffold_hub

    # So this value will be the :git address of a folder, or else a name I look up on my new gallery site.
    # So to do next: use this value to get a different folder from here!
    class_option :view, :default => 'default', :banner => "VIEW_NAME", :type => :string, :desc => "View tempates to use"

    def debug
      puts "DEBUG view option was #{options[:view]}"
    end

#    protected
#
#    def info
#
#      if options[:view] == 'rails_default'
#        path = '/scaffolds/1/info.text'
#      else
#        path = '/scaffolds/2/info.text'
#      end
#      info = ''
#      Net::HTTP.start('localhost', 3000) do |http|
#        info = YAML::load(http.get(path).body)
#      end
#      info
#    end
#
#    def download_controller_file(template_file)
#      local_path = Tempfile.new(template_file[:name]).path
#      puts "DEBUG download to #{local_path}"
#
#      url = URI.parse(template_file[:url])
#      puts "DEBUG download from #{url.inspect}"
#
#      Net::HTTP.start(url.host, url.port) do |http|
#        resp = http.get(url.path)
#        open(local_path, "wb") do |file|
#          file.write(resp.body)
#        end
#      end
#
#      template local_path, File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
#      #template local_path, File.join("app/controllers", controller_file_path, template_file[:name])
#      #puts `ls -l /var/folders/kW/kW-W-aidH1qhj9KHKk9kzE+++TI/-Tmp-`
#    end
#    
end


  #hook_for :scaffold_controller, :required => true
  #hook_for :stylesheets

  #attr_reader :model

#    def initialize(args, opts, config)
#      super
#      p self.class.hooks
#    end
  #def initialize(args, opts, config)
  #  super
  #  @model = ViewMapper::ModelInfo.new(@name)
  #end

  #def attributes
    #[ 'one', 'two' ].collect { |col| Rails::Generator::GeneratedAttribute.new col.name, col.type }
  #end
#end
