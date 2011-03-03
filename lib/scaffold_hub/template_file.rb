module ScaffoldHub
  class TemplateFile < RemoteFile

    def initialize(file_spec, scaffold, local)
      @spec_src  = file_spec[:src]
      @spec_dest = file_spec[:dest]
      @scaffold  = scaffold
      @local     = local
    end

    def src
      if @local
        File.join(File.dirname(@scaffold), @spec_src)
      else
        @local_path
      end
    end

    def dest
      File.join(@spec_dest, File.basename(@spec_src))
    end

    def download
      @local_path = Tempfile.new(File.basename(@spec_src)).path
      open(@local_path, "wb") do |file|
        file.write(super)
      end
    end

    def url
      "http://scaffoldhub.org/scaffolds/#{@scaffold}/#{@spec_src}"
    end

  end
end
