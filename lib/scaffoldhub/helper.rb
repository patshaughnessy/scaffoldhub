require 'tmpdir'

module Scaffoldhub
  module Helper

    class ScaffoldParameterMissing < RuntimeError
    end

    def self.included(base)
      base.class_eval do
        source_root Dir.tmpdir
      end
    end

    class << self
      def scaffold_spec
        @scaffold_spec
      end

      def scaffold_spec=(scaffold)
        @scaffold_spec = scaffold
      end
    end

    def each_template_file(type)
      begin
        scaffold_spec.select_files(type).each do |template_file|
          yield template_file.download!
          template_file.close
        end
      rescue Errno::ENOENT => e
        say_status :error, e.message, :red
        raise e
      rescue Scaffoldhub::NotFoundException => e
        say_status :error, "HTTP 404 error - did you misspell \"#{scaffold_name}\"?", :red
        raise e
      rescue Scaffoldhub::NetworkErrorException => e
        say_status :error, "HTTP error connecting to #{e.message}", :red
        raise e
      end
    end

    def find_template_file(type)
      begin
        template_file = scaffold_spec.find_file(type)
        if template_file
          yield template_file.download!
          template_file.close
        end
      rescue Errno::ENOENT => e
        say_status :error, e.message, :red
        raise e
      rescue Scaffoldhub::NotFoundException => e
        say_status :error, "HTTP 404 error - did you misspell \"#{scaffold_name}\"?", :red
        raise e
      rescue Scaffoldhub::NetworkErrorException => e
        say_status :error, "HTTP error connecting to #{e.message}", :red
        raise e
      end
    end

    def each_gem
      begin
        if (gems = scaffold_spec.gems)
          gems.each { |gem| yield gem }
        end
      rescue Errno::ENOENT => e
        say_status :error, e.message, :red
        raise e
      rescue Scaffoldhub::NotFoundException => e
        say_status :error, "HTTP 404 error - did you misspell \"#{scaffold_name}\"?", :red
        raise e
      rescue Scaffoldhub::NetworkErrorException => e
        say_status :error, "HTTP error connecting to #{e.message}", :red
        raise e
      end
    end

    def scaffold_spec
      Helper.scaffold_spec ||= download_scaffold_spec!
    end

    def download_scaffold_spec!
      scaffold_spec = ScaffoldSpec.new(scaffold_name, options[:local], status_proc)
      scaffold_spec.download_and_parse!
      if scaffold_spec.parameter_example && scaffold_parameter.nil?
        say_status :error, parameter_missing_message(scaffold_spec.parameter_example), :red
        raise ScaffoldParameterMissing
      end
      scaffold_spec
    end

    def scaffold_name
      parse_scaffold_option(0)
    end

    def scaffold_parameter
      parse_scaffold_option(1)
    end

    def replace_name_tokens(dest)
      result = dest.gsub(/PLURAL_NAME/, file_name.pluralize).gsub(/NAME/, file_name)
      result.gsub!(/SCAFFOLD_PARAMETER/, scaffold_parameter) unless scaffold_parameter.nil?
      result
    end

    def post_install_message
      message = scaffold_spec.post_install_message
      replace_name_tokens(message) if message
    end

    def status_proc
      @status_proc ||= lambda { |url| say_status :download, url }
    end

    private

    def parse_scaffold_option(index)
      options[:scaffold].split(':')[index]
    end

    def parameter_missing_message(example)
      "Scaffold parameter missing; please specify the #{example} after the scaffold name like this: --scaffold #{scaffold_name}:#{example}"
    end
  end
end
