module ScaffoldHub
  module Helper

    def self.scaffold
      @scaffold
    end

    def self.scaffold=(scaffold)
      @scaffold = scaffold
    end

    def each_template_file(type)
      begin
        ScaffoldHub::Helper.scaffold ||= ScaffoldHub::Scaffold.new(options[:scaffold], options[:local], status_proc)
        ScaffoldHub::SpecFile.new(status_proc).select_files(type).each do |template_file|
          if options[:local]
            raise Errno::ENOENT.new(template_file.src) unless File.exists?(template_file.src)
          else
            template_file.download
          end
          yield template_file
        end
      rescue Errno::ENOENT
        say_status :error, "File not found error for #{File.expand_path(options[:scaffold])}", :red
      rescue ScaffoldHub::NotFoundException => e
        say_status :error, "HTTP 404 not found error for #{e.message}", :red
      rescue ScaffoldHub::NetworkErrorException => e
        say_status :error, "HTTP error connecting to #{e.message}", :red
      end
    end

    def status_proc
      @proc ||= lambda { |url| say_status :download, url }
    end
  end
end
