require 'rails/generators/erb/scaffold/scaffold_generator'
require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
require 'rails/generators/active_record/model/model_generator'

class NewScaffoldhubGenerator < Rails::Generators::NamedBase

  def self.source_root
    File.expand_path('../templates', __FILE__)
  end

  def copy_scaffold_spec
    template 'scaffold_spec.rb.erb', "#{singular_name}_scaffold/scaffold_spec.rb"
  end

  def copy_scaffold_screenshot
    copy_file 'screenshot.png', "#{singular_name}_scaffold/#{singular_name}_screenshot.png"
  end

  def copy_rails_erb_templates
    %w[ _form.html.erb edit.html.erb index.html.erb new.html.erb show.html.erb ].each do |file_name|
      copy_file File.join(Erb::Generators::ScaffoldGenerator.default_source_root, file_name),
                "#{singular_name}_scaffold/templates/#{file_name}"
    end
  end

  def copy_rails_model_template
    copy_file File.join(ActiveRecord::Generators::ModelGenerator.default_source_root, 'model.rb'),
              "#{singular_name}_scaffold/templates/model.rb"
    copy_file File.join(ActiveRecord::Generators::ModelGenerator.default_source_root, 'migration.rb'),
              "#{singular_name}_scaffold/templates/migration.rb"
  end

  def copy_rails_controller_template
    copy_file File.join(Rails::Generators::ScaffoldControllerGenerator.default_source_root, 'controller.rb'),
              "#{singular_name}_scaffold/templates/controller.rb"
  end
end
