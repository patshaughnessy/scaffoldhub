module ScaffoldHub
  class SpecLocation < RemoteFile

    def initialize(scaffold, local)
      @scaffold = scaffold
      @local    = local
    end

    def url
      url = "http://scaffoldhub.org/scaffolds/#{@scaffold}/spec"
    end

    def location
      if @local
        @scaffold
      else
        download
      end
    end

  end
end
