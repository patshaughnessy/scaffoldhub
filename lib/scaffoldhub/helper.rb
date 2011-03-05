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
          if options[:local]
            raise Errno::ENOENT.new(template_file.src) unless File.exists?(template_file.src)
          else
            template_file.download!
          end
          yield template_file
        end
      rescue Errno::ENOENT => e
        say_status :error, e.message, :red
      rescue Scaffoldhub::NotFoundException => e
        say_status :error, "HTTP 404 not found error for #{e.message}", :red
      rescue Scaffoldhub::NetworkErrorException => e
        say_status :error, "HTTP error connecting to #{e.message}", :red
      end
    end

    def scaffold_spec
      Helper.scaffold_spec ||= download_scaffold_spec!
    end

    def download_scaffold_spec!
      scaffold_spec = ScaffoldSpec.new(options[:scaffold], options[:local], status_proc)
      scaffold_spec.download_and_parse!
      scaffold_spec
    end

    def status_proc
      @status_proc ||= lambda { |url| say_status :download, url }
    end
  end
end
