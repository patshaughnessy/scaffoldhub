module ScaffoldHub
  class SpecFile < RemoteFile

    def initialize(location, local)
      @location = location
      @local    = local
    end

    def url
      url = @location
    end

    def select_files(type)
      if @local
        load_local
      else
        load_remote
      end
      @spec[:files].select { |file_spec| file_spec[:type] == type.to_s }
    end

    protected

    def load_local
      parse(File.new(@location).read)
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
