require 'rails/generators/erb/scaffold/scaffold_generator'

module Erb
  class ScaffoldhubGenerator < Erb::Generators::ScaffoldGenerator

    include Scaffoldhub::Helper

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    def copy_view_files
      each_template_file(:erb) do |erb_template_file|
        unless erb_template_file.dest == 'app/views/layouts/layout.erb'
          template erb_template_file.src, File.join("app/views", controller_file_path, erb_template_file.dest)
        end
      end
    end

    def copy_layout_file
      layout_template = find_template_file('erb', 'templates/layout.erb')
      template layout_template.src, File.join('app/views/layouts', "#{controller_file_name}.html.erb") if layout_template
    end
  end
end
