require 'rails/generators/erb/scaffold/scaffold_generator'

module Erb
  class ScaffoldhubGenerator < Erb::Generators::ScaffoldGenerator

    include Scaffoldhub::Helper

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    def copy_view_files
      each_template_file(:view) do |erb_template_file|
        if is_layout_erb?(erb_template_file)
          copy_layout_file(erb_template_file)
        else
          template erb_template_file.src, File.join("app/views", controller_file_path, erb_template_file.dest)
        end
      end
    end

    private

    def copy_layout_file(layout_template)
      template layout_template.src, File.join('app/views/layouts', "#{controller_file_name}.html.erb")
    end

    def is_layout_erb?(template_file)
      template_file.dest == 'app/views/layouts/layout.erb'
    end
  end
end
