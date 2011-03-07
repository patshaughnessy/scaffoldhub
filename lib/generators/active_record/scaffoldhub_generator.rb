require 'rails/generators/active_record'
require 'rails/generators/active_record/model/model_generator'

module ActiveRecord
  class ScaffoldhubGenerator < ActiveRecord::Generators::ModelGenerator

    include Scaffoldhub::Helper

    source_root File.join(base_root, 'active_record', 'model', 'templates')

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    def create_model_file
      model_template = find_template_file('active_record', 'templates/model.rb')
      template model_template.src, File.join('app/models', class_path, "#{file_name}.rb") if model_template
    end

  end
end
