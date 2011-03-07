module Scaffoldhub
  module Helper

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
        end
      rescue Errno::ENOENT => e
        say_status :error, e.message, :red
      rescue Scaffoldhub::NotFoundException => e
        say_status :error, "HTTP 404 not found error for #{e.message}", :red
      rescue Scaffoldhub::NetworkErrorException => e
        say_status :error, "HTTP error connecting to #{e.message}", :red
      end
    end

    def find_template_file(type, name)
      begin
        template_file = scaffold_spec.find_file(type, name)
        template_file.download! unless template_file.nil?
      rescue Errno::ENOENT => e
        say_status :error, e.message, :red
        nil
      rescue Scaffoldhub::NotFoundException => e
        say_status :error, "HTTP 404 not found error for #{e.message}", :red
        nil
      rescue Scaffoldhub::NetworkErrorException => e
        say_status :error, "HTTP error connecting to #{e.message}", :red
        nil
      end
    end

    def scaffold_spec
      Helper.scaffold_spec ||= download_scaffold_spec!
    end

    def download_scaffold_spec!
      scaffold_spec = ScaffoldSpec.new(scaffold_name, options[:local], status_proc)
      scaffold_spec.download_and_parse!
      scaffold_spec
    end

    def scaffold_name
      parse_scaffold_option(0)
    end

    def scaffold_parameter
      parse_scaffold_option(1)
    end

    def status_proc
      @status_proc ||= lambda { |url| say_status :download, url }
    end

    private

    def parse_scaffold_option(index)
      options[:scaffold].split(':')[index]
    end

  end
end
