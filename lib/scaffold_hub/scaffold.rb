module ScaffoldHub
  class Scaffold < RemoteFile

    SERVER_NAME = 'scaffoldhub.org'

    def initialize(scaffold, local, status_proc)
      @scaffold    = scaffold
      @local       = local
      super(status_proc)
    end

    def base_url
      if @local
        File.dirname(File.expand_path(@scaffold))
      else
        spec_url.split(/\/(?=[^\/]+(?: |$))/)[0]
      end
    end

    def spec_url
      @spec_url ||=
        if @local
          @scaffold
        else
          download.strip
        end
    end

    def local
      @local
    end

    def url
      "http://#{SERVER_NAME}/scaffolds/#{@scaffold}/spec"
    end

  end
end
