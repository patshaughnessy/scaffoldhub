require 'net/http'

module Scaffoldhub

  class NotFoundException < RuntimeError
  end

  class NetworkErrorException < RuntimeError
  end

  class RemoteFile

    def initialize(status_proc)
      @status_proc = status_proc
    end

    def download
      begin
        uri = URI.parse(url)
        @status_proc.call(url)
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
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise NetworkErrorException.new(url)
      end
    end

  end
end
