module ScaffoldHub
  class TemplateFile < RemoteFile

    def initialize(src, dest, status_proc)
      @src      = src
      @dest     = dest || ''
      @base_url = ScaffoldHub::Helper.scaffold.base_url
      super(status_proc)
    end

    def src
      if ScaffoldHub::Helper.scaffold.local
        File.join(@base_url, @src)
      else
        @local_path
      end
    end

    def dest
      File.join(@dest, File.basename(@src))
    end

    def download
      @local_path = Tempfile.new(File.basename(@src)).path
      open(@local_path, "wb") do |file|
        file.write(super)
      end
    end

    def url
      "#{@base_url}/#{@src}"
    end

  end
end
