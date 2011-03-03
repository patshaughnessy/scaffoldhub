module ScaffoldHub
  class SpecFile < RemoteFile

    def initialize(scaffold, local)
      @scaffold = scaffold
      @local    = local
    end

    def load
      if @local
        load_local
      else
        load_remote
      end
    end

    def url
      url = "http://scaffoldhub.org/scaffolds/#{@scaffold}/#{@scaffold}.scaffoldspec"
    end

    protected

    def load_local
      parse(File.new(@scaffold).read)
    end

    def load_remote
      parse(download)
    end

    def parse(data)
      @spec = YAML::load(data) unless data.nil?
    end

    def method_missing(name, *args, &blk)
      @spec.send(name)
    end
  end
end
