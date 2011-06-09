require 'rails/generators/rails/helper/helper_generator'

module Helper
  class ScaffoldhubGenerator < Rails::Generators::HelperGenerator

    include Scaffoldhub::Helper

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    def create_helper_files
      each_template_file(:helper) do |helper_template_file|
        template helper_template_file.src, File.join("app/helpers", class_path, "#{file_name}_helper.rb")
      end
    end
  end
end
