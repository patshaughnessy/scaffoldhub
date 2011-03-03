require 'net/http'
require 'rails/generators/erb/scaffold/scaffold_generator'

module Erb
  class ScaffoldHubGenerator < Erb::Generators::ScaffoldGenerator
    source_root File.expand_path('../templates', __FILE__)

    # So this value will be the :git address of a folder, or else a name I look up on my new gallery site.
    # So to do next: use this value to get a different folder from here!
    class_option :view, :default => 'default', :banner => "VIEW_NAME", :type => :string, :desc => "View tempates to use"

    argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

    def create_root_folder
      empty_directory File.join("app/views", controller_file_path)
    end

    def copy_view_files
      puts "DEBUG info #{info.inspect}"
      info[:template_files].each do |file|
        if file[:type] == 'erb'
          download_view_file(file)
        #else
          #download_controller_file(file)
        end
      end
    end

    protected

    def info
      if options[:view] == 'rails_default'
        path = '/scaffolds/1/info.text'
      else
        path = '/scaffolds/2/info.text'
      end
      info = ''
      Net::HTTP.start('localhost', 3000) do |http|
        info = YAML::load(http.get(path).body)
      end
      info
    end

    def download_view_file(template_file)
      local_path = Tempfile.new(template_file[:name]).path
      puts "DEBUG download to #{local_path}"

      url = URI.parse(template_file[:url])
      puts "DEBUG download from #{url.inspect}"

      Net::HTTP.start(url.host, url.port) do |http|
        resp = http.get(url.path)
        open(local_path, "wb") do |file|
          file.write(resp.body)
        end
      end

      template local_path, File.join("app/views", controller_file_path, template_file[:name])
      #puts `ls -l /var/folders/kW/kW-W-aidH1qhj9KHKk9kzE+++TI/-Tmp-`
    end

  end
end

#
#
#
#require 'rails/generators/erb'
#require 'rails/generators/resource_helpers'
#
#module Erb
#  module Generators
#    class ScaffoldGenerator < Base
#      include Rails::Generators::ResourceHelpers
#
#      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
#
#      def create_root_folder
#        empty_directory File.join("app/views", controller_file_path)
#      end
#
#      def copy_view_files
#        available_views.each do |view|
#          filename = filename_with_extensions(view)
#          template filename, File.join("app/views", controller_file_path, filename)
#        end
#      end
#
#    protected
#
#      def available_views
#        %w(index edit show new _form)
#      end
#    end
#  end
#end

