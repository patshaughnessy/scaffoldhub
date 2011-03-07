require 'net/https'

module Scaffoldhub

  class NotFoundException < RuntimeError
  end

  class NetworkErrorException < RuntimeError
  end

  class RemoteFile

    def initialize(status_proc)
      @status_proc = status_proc
    end

    def remote_file_contents!
      begin
        uri = URI.parse(url)
        @status_proc.call(url)
        if uri.port == 443
          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true
          https.verify_mode = OpenSSL::SSL::VERIFY_NONE
          https.start do |https|
            response_body(https.get(uri.path))
          end
        else
          Net::HTTP.start(uri.host, uri.port) do |http|
            response_body(http.get(uri.path))
          end
        end
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise NetworkErrorException.new(url)
      end
    end

    def response_body(resp)
      if resp.code.to_i == 200
        resp.body
      elsif resp.code.to_i == 404
        raise NotFoundException.new(url)
      else
        raise NetworkErrorException.new(url)
      end
    end

  end
end
