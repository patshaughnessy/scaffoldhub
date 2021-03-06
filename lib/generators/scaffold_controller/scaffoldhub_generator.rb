require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module ScaffoldController
  class ScaffoldhubGenerator < Rails::Generators::ScaffoldControllerGenerator

    include Scaffoldhub::Helper

    remove_hook_for :template_engine
    hook_for        :template_engine, :as => :scaffoldhub

    remove_hook_for :helper
    # Invoke the helper using the controller name (pluralized)
    hook_for        :helper, :as => :scaffoldhub do |invoked|
      invoke invoked, [ controller_name ]
    end

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    def create_controller_files
      find_template_file(:controller) do |controller_template_file|
        template controller_template_file.src, File.join('app/controllers', class_path, "#{controller_file_name}_controller.rb")
      end
    end
  end
end
