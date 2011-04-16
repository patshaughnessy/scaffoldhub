require 'net/https'

module Scaffoldhub

  class NotFoundException < RuntimeError
  end

  class NetworkErrorException < RuntimeError
  end

  class RemoteFile

    attr_accessor :url

    def initialize(url = nil, status_proc = nil)
      @status_proc = status_proc
      @url = url
    end

    def exists?
      http_request.code.to_i == 200
    end

    def remote_file_contents!
      resp = http_request
      if resp.code.to_i == 200
        resp.body
      elsif resp.code.to_i == 404
        raise NotFoundException.new(url)
      else
        raise NetworkErrorException.new(url)
      end
    end

    def http_request
      begin
        @status_proc.call(url) if @status_proc
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.port == 443
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.start do |http|
          http.get(uri.path)
        end
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        raise NetworkErrorException.new(url)
      end
    end

  end
end
