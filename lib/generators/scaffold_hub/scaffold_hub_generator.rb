require 'scaffold_hub/remote_file'
require 'scaffold_hub/spec_file'
require 'scaffold_hub/template_file'

require 'rails/generators/rails/scaffold/scaffold_generator'

class ScaffoldHubGenerator < Rails::Generators::ScaffoldGenerator
  #source_root File.expand_path('../templates', __FILE__)

  #remove_hook_for :controller
  #hook_for        :controller, :as => :scaffold_hub
  #
#  remove_hook_for :template_engine
#  hook_for :template_engine, :as => :scaffold_hub

    # So this value will be the :git address of a folder, or else a name I look up on my new gallery site.
    # So to do next: use this value to get a different folder from here!
    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

#    def debug
#      puts "DEBUG scaffold option was #{options[:scaffold]}"
#      if options[:local]
#        puts "DEBUG local option was true"
#      else
#        puts "DEBUG local option was false"
#      end
#
#      load_spec
#      puts "DEBUG info is #{@info.inspect}"
#    end


  def download_and_copy_files
    begin
      scaffold_spec[:files].each do |file_spec|
        download_and_copy_one_file(file_spec)
      end
    rescue Errno::ENOENT, ScaffoldHub::NotFoundException => e
      say_status :error, "Cound not find file #{e.message}", :red
    rescue Exception => e
      say_status :error, "Network error downloading #{e.message}.", :red
    end
  end

  protected

  def download_and_copy_one_file(file_spec)
    template_file = ScaffoldHub::TemplateFile.new(file_spec, options[:scaffold], options[:local])
    unless options[:local]
      say_status :download, template_file.url
      template_file.download
    end
    template template_file.src, template_file.dest
  end

  def scaffold_spec
    @spec ||= load_spec
  end

  def load_spec
    spec_file = ScaffoldHub::SpecFile.new(options[:scaffold], options[:local])
    say_status :download, spec_file.url unless options[:local]
    spec_file.load
  end
end

