Scaffoldhub::Specification.new do

  # Github URL where you will post your scaffold - the speciied folder must contain this file
  base_url  'https://github.com/your_name/your_repo'

  # The name of your new scaffold: should be a single word
  name 'test_scaffold'

  # Metadata about this scaffold - this info is only used for display on scaffoldhub.org:
  metadata do

    # A short paragraph describing what this scaffold does
    description 'The test_scaffold scaffold.'

    # 4x3 aspect ratio screen shot
    screenshot 'screenshot.png'

    # Tag(s) to help scaffoldhub.org users find your scaffold
    tag 'jquery'
    tag 'autocomplete'

    # Optionally specify an example of a scaffold parameter
    parameter_example 'FIELD_NAME'

    # Optionally post a link to an article you write explaining how the scaffold works.
    blog_post 'http://patshaughnessy.net/2011/3/13/view-mapper-for-rails-3-scaffoldhub'
  end

  # Define a model template - this ERB file will be used to generate a new
  # model class with this path & filename: app/models/NAME.rb
  model 'templates/model.rb'

  # Define a controller template - this ERB file will be used to generate a new
  # controller class with this path & filename: app/controllers/PLURAL_NAME.rb
  controller 'templates/controller.rb'

  # Define a view template - this ERB file will be used to generate a new
  # view file with this path & filename: app/views/PLURAL_NAME/view_file_name.rb
  view 'templates/_form.html.erb'

  helper 'templates/helper.rb', :rename => 'NAME_helper.rb'

  gem 'some_gem', '1.0'
  gem "some_other_gem", :group => :test, :git => "git://github.com/rails/rails"

  # You can use "with_options" to specify the same source folder for a series of templates:
  with_options :src => 'templates' do
    view 'new.html.erb'
    view 'edit.html.erb'
    view 'index.html.erb'
    view 'show.html.erb'
    view 'partial.erb', :rename => '_NAME.html.erb'
  end

  # Specify some other code file that should be generated from an ERB template; use
  # the :dest option is required to indicate where the generated file should go
  template 'templates/other_code_file.erb', :dest => 'lib/other_code_file.rb'

  # Specify some other file that should be simply copied into the target app somwhere
  # the :dest option is required to indicate where the generated file should go
  file 'templates/jquery/jquery-1.4.4.min.js', :dest => 'public/javascripts'

  with_options :src => 'templates/jquery', :dest => 'public/javascripts' do
    file 'jquery-ui-1.8.10.custom.min.js'

    # You can use with_options recursively - both the :src and :dest options values
    # will be constructed relative to the parent with_option values.
    with_options :src => 'ui-lightness', :dest => 'ui-lightness' do
      file 'jquery-ui-1.8.10.custom.css'
      with_options :src => 'images', :dest => 'images' do
        file 'ui-bg_diagonals-thick_18_b81900_40x40.png'
        file 'ui-bg_diagonals-thick_20_666666_40x40.png'
        file 'ui-bg_flat_10_000000_40x100.png'
        file 'ui-bg_glass_100_f6f6f6_1x400.png'
        file 'ui-bg_glass_100_fdf5ce_1x400.png'
        file 'ui-bg_glass_65_ffffff_1x400.png'
        file 'ui-bg_gloss-wave_35_f6a828_500x100.png'
        file 'ui-bg_highlight-soft_100_eeeeee_1x100.png'
        file 'ui-bg_highlight-soft_75_ffe45c_1x100.png'
        file 'ui-icons_222222_256x240.png'
        file 'ui-icons_228ef1_256x240.png'
        file 'ui-icons_ef8c08_256x240.png'
        file 'ui-icons_ffd27a_256x240.png'
      end
      file 'images/ui-icons_ffffff_256x240.png', :dest => 'images'
    end
  end

  post_install_message 'Please do this, this and that.'
end
