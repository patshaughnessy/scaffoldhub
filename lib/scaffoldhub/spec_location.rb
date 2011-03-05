module Scaffoldhub
  class SpecLocation < RemoteFile

    SERVER_NAME = 'scaffoldhub.org'

    def initialize(scaffold, local, status_proc)
      @scaffold    = scaffold
      @local       = local
      super(status_proc)
    end

    def url
      "http://#{SERVER_NAME}/scaffolds/#{@scaffold}/spec"
    end

    def download_location!
      if @local
        @scaffold
      else
        remote_file_contents!.strip
      end
    end

  end
end
