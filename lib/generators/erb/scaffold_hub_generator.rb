require 'rails/generators/erb/scaffold/scaffold_generator'

module Erb
  class ScaffoldHubGenerator < Erb::Generators::ScaffoldGenerator

    include ScaffoldHub::Helper

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    def copy_view_files
      each_template_file(:erb) do |erb_template_file|
        template erb_template_file.src, File.join("app/views", controller_file_path, erb_template_file.dest)
      end
    end
  end
end
