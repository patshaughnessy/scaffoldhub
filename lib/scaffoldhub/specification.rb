module Scaffoldhub
  class Specification

    @@files  = []

    class << self
      def files
        @@files
      end

      def add_file(type, src, dest)
        puts "DEBUG add file type #{type} #{src} #{dest}"
        @@files << { :type => type, :src => src, :dest => dest }
      end
    end

    def initialize
      yield self
    end

    def method_missing(name, *args, &blk)
      if name.to_s =~ /(.*)_file/ && args[0].is_a?(Hash)
        self.class.add_file($1, args[0][:src], args[0][:dest])
      end
    end

  end
end
