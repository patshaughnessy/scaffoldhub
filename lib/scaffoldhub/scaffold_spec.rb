module Scaffoldhub
  class ScaffoldSpec < RemoteFile

    SCAFFOLD_HUB_SERVER = 'scaffoldhub.org'

    def initialize(url, local, status_proc)
      @scaffold    = url
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
      template_file_specs.select { |file_spec| file_spec[:type] == type.to_s }.collect do |file_spec|
        TemplateFile.new file_spec[:src], file_spec[:dest], @local, base_url, @status_proc
      end
    end

    def find_file(type, name)
      file_spec = template_file_specs.detect { |file_spec| file_spec[:src] == name && file_spec[:type] == type }
      unless file_spec.nil?
        TemplateFile.new file_spec[:src], file_spec[:dest], @local, base_url, @status_proc
      end
    end

    def parse_local
      if File.exists?(url)
        require url
      else
        raise Errno::ENOENT.new(url)
      end
    end

    def parse_remote!
      @spec = YAML::load(remote_file_contents!)
    end

    def template_file_specs
      if @local
        Specification.files
      else
        @spec[:files]
      end
    end

    def url
      if @local
        @scaffold
      else
        "http://#{SCAFFOLD_HUB_SERVER}/scaffolds/#{@scaffold}/spec"
      end
    end

    def base_url
      if @local
        File.dirname(File.expand_path(@scaffold))
      else
        @spec[:base_url]
      end
    end

  end
end
