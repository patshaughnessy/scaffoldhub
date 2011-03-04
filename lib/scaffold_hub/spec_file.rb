module ScaffoldHub
  class SpecFile < RemoteFile

    def initialize(status_proc)
      @status_proc = status_proc
      super(status_proc)
    end

    def url
      ScaffoldHub::Helper.scaffold.spec_url
    end

    def select_files(type)
      if ScaffoldHub::Helper.scaffold.local
        load_local
      else
        load_remote
      end
      @spec[:files].select { |file_spec| file_spec[:type] == type.to_s }.collect do |file_spec|
        TemplateFile.new file_spec[:src], file_spec[:dest], @status_proc
      end
    end

    protected

    def load_local
      parse(File.new(url).read)
    end

    def load_remote
      parse(download)
    end

    def parse(data)
      @spec = YAML::load(data) unless data.nil?
    end

    #def method_missing(name, *args, &blk)
      ##@spec.send(name)
    #end
  end
end
