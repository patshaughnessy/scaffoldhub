require 'net/http'

module ScaffoldHub

  class NotFoundException < RuntimeError
  end

  class NetworkErrorException < RuntimeError
  end

  class RemoteFile

    def download
      begin
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port) do |http|
          resp = http.get(uri.path)
          if resp.code.to_i == 200
            resp.body
          elsif resp.code.to_i == 404
            raise NotFoundException.new(url)
          else
            raise NetworkErrorException.new(url)
          end
        end
      rescue NotFoundException
        raise
      rescue Exception
        raise NetworkErrorException.new(url)
      end
    end

  end
end
