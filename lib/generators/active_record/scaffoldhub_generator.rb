require 'rails/generators/active_record'
require 'rails/generators/active_record/model/model_generator'

module ActiveRecord
  class ScaffoldhubGenerator < ActiveRecord::Generators::ModelGenerator

    include Scaffoldhub::Helper

    source_root File.join(base_root, 'active_record', 'model', 'templates')

    class_option :scaffold, :default => 'default', :banner => "SCAFFOLD_NAME",  :type => :string,  :desc => "Scaffold to use"
    class_option :local,    :default => false,     :banner => "LOCAL SCAFFOLD", :type => :boolean, :desc => "Use a local scaffold, not scaffoldhub.org"

    class_option :migration,  :type => :boolean
    class_option :timestamps, :type => :boolean
    class_option :parent,     :type => :string, :desc => "The parent class for the generated model"

    def create_model_file
      model_template = find_template_file('active_record', 'templates/model.rb')
      template model_template.src, File.join('app/models', class_path, "#{file_name}.rb") if model_template
    end

    def create_migration_file
      return unless options[:migration] && options[:parent].nil?
      migration_template = find_template_file('active_record', 'templates/migration.rb')
      migration_template migration_template.src, "db/migrate/create_#{table_name}.rb" if migration_template
    end

  end
end
