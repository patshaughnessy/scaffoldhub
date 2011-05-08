module Scaffoldhub
  class TemplateFile < RemoteFile

    def initialize(src, dest, rename, local, base_url, status_proc)
      @src      = src
      @dest     = dest || ''
      @rename   = rename
      @local    = local
      @base_url = base_url
      super(url, status_proc)
    end

    def src
      if @local
        File.join(@base_url, @src)
      else
        @local_path
      end
    end

    def dest
      if @rename
        File.join(@dest, @rename)
      else
        File.join(@dest, File.basename(@src))
      end
    end

    def download!
      if @local
        raise Errno::ENOENT.new(src) unless File.exists?(src)
      else
        @local_path = Tempfile.new(File.basename(@src)).path
        open(@local_path, "wb") do |file|
          file.write(remote_file_contents!)
        end
      end
      self
    end

    def url
      "#{@base_url}/#{@src}"
    end

  end
end
