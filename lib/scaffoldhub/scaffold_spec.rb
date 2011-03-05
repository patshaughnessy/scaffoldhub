module Scaffoldhub
  class ScaffoldSpec < RemoteFile

    attr_accessor :url

    def initialize(url, local, status_proc)
      @url         = url
      @local       = local
      @status_proc = status_proc
      super(@status_proc)
    end

    def download_and_parse!
      if @local
        parse_local
      else
        parse_remote!
      end
    end

    def select_files(type)
      Specification.files.select { |file_spec| file_spec[:type] == type.to_s }.collect do |file_spec|
        TemplateFile.new file_spec[:src], file_spec[:dest], @local, base_url, @status_proc
      end
    end

    protected

    def parse_local
      if File.exists?(url)
        require url
      else
        raise Errno::ENOENT.new(url)
      end
    end

    def parse_remote!
      eval(remote_file_contents!)
    end

    def base_url
      if @local
        File.dirname(File.expand_path(@url))
      else
        @url.split(/\/(?=[^\/]+(?: |$))/)[0]
      end
    end

  end
end
