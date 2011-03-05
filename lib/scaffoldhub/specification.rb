module Scaffoldhub
  class Specification

    @@files  = []
    @@base_url = nil

    class << self
      def files
        @@files
      end

      def files=(files)
        @@files = files
      end

      def add_file(type, src, dest)
        @@files << { :type => type, :src => src, :dest => dest }
      end

      def base_url
        @@base_url
      end

      def base_url=(url)
        @@base_url = url
      end
    end

    def initialize
      yield self
    end

    def method_missing(name, *args, &blk)
      if name.to_s =~ /(.*)_file/ && args[0].is_a?(Hash)
        self.class.add_file($1, args[0][:src], args[0][:dest])
      elsif name == :base_url
        self.class.base_url = args[0]
      end
    end

  end
end
