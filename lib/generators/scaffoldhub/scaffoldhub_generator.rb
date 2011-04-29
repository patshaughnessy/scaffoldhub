require 'rails/generators/rails/scaffold/scaffold_generator'

class ScaffoldhubGenerator < Rails::Generators::ScaffoldGenerator

  include Scaffoldhub::Helper

  remove_hook_for :scaffold_controller
  hook_for        :scaffold_controller, :as => :scaffoldhub

  remove_hook_for :orm
  hook_for        :orm, :as= => :scaffoldhub

  class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
  class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

  def download_and_copy_other_files
    each_template_file(:template) do |template_file|
      template template_file.src, template_file.dest
    end
    each_template_file(:file) do |template_file|
      copy_file template_file.src, template_file.dest
    end
  end
end
