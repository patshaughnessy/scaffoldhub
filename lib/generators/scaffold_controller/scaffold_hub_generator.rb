require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module ScaffoldController
  class ScaffoldHubGenerator < Rails::Generators::ScaffoldControllerGenerator

    include ScaffoldHub::Helper

    remove_hook_for :template_engine
    hook_for        :template_engine, :as => :scaffold_hub

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    def create_controller_files
      each_template_file(:controller) do |controller_template_file|
        template controller_template_file.src, File.join('app/controllers', class_path, controller_template_file.dest)
      end
    end
  end
end
