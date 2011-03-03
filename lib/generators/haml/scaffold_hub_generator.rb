require 'net/http'
require 'rails/generators/erb/scaffold/scaffold_generator'

module Haml
  class ScaffoldHubGenerator < Erb::Generators::ScaffoldGenerator
    source_root File.expand_path('../templates', __FILE__)

    SCAFFOLD_HUB_SERVER = 'github.com'
    SCAFFOLD_HUB_PORT = 80
    SCAFFOLD_HUB_PATH = 'scaffolds/lib/generators'

    # So this value will be the :git address of a folder, or else a name I look up on my new gallery site.
    # So to do next: use this value to get a different folder from here!
    class_option :view, :default => 'default', :banner => "VIEW_NAME", :type => :string, :desc => "View tempates to use"

    argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
    #def attributes2
      #[ 'blah:string' ]
    #end

    def copy_view_files
      available_views.each do |view|
        filename = filename_with_extensions(view)
        download_view_file(filename)
        template filename, File.join("app/views", controller_file_path, filename)
      end
    end

    protected

    def handler
      :haml
    end

    def download_view_file(filename)

      url_path = "/#{SCAFFOLD_HUB_PATH}/#{options[:view]}/templates/#{filename}"
      local_path = File.expand_path(File.join(self.class.source_root, filename))

      puts "DEBUG download from #{SCAFFOLD_HUB_SERVER}:#{SCAFFOLD_HUB_PORT}#{url_path}"
      puts "DEBUG download to #{local_path}"

      Net::HTTP.start(SCAFFOLD_HUB_SERVER, SCAFFOLD_HUB_PORT) do |http|
        resp = http.get(url_path)
        open(local_path, "wb") do |file|
          file.write(resp.body)
        end
      end
    end

    # Also to do: get these names from the web site!
    def available_views
      %w(index edit show new _form)
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

