module ScaffoldHub
  module Helper
    def each_template_file(type)
      begin
        scaffold_spec_file = ScaffoldHub::SpecFile.new(options[:scaffold], options[:local])
        scaffold_spec_file.select_files(type).each do |file_spec|
          yield download_one_file(file_spec)
        end
      rescue Errno::ENOENT, ScaffoldHub::NotFoundException => e
        say_status :error, "Cound not find file #{e.message}", :red
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        say_status :error, "Network error downloading #{e.message}.", :red
      end
    end

    def download_one_file(file_spec)
      template_file = ScaffoldHub::TemplateFile.new(file_spec, options[:scaffold], options[:local])
      unless options[:local]
        say_status :download, template_file.url
        template_file.download
      end
      template_file
    end
  end
end
