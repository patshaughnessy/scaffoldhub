require 'yaml'

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

      def add_file(src, dest, type)
        @@files << { :type => type, :src => src, :dest => dest }
      end

      def base_url
        @@base_url
      end

      def base_url=(path)
        @@base_url = path
      end

      def blog_post
        @@blog_post
      end

      def blog_post=(url)
        @@blog_post = url
      end

      def to_yaml
        {
          :base_url  => base_url,
          :blog_post => blog_post,
          :files => files
        }.to_yaml
      end
    end

    def initialize(&block)
      @context_stack = []
      @context_options = {}
      instance_eval(&block) if block_given?
    end

    def with_options(options, &block)
      @context_stack.push(@context_options)
      @context_options = options_relative_to_parent(@context_options, options)
      yield if block_given?
      @context_options = @context_stack.pop
    end

    def file(src, options = {}, type = :file)
      self.class.add_file(
        join_with_parent(@context_options[:src], src),
        join_with_parent(@context_options[:dest], options[:dest]),
        type
      )
    end

    def template(src, options = {})
      raise ':dest option is required for templates' unless options[:dest]
      file(src, options, :template)
    end

    def model(src, options = {})
      file(src, options, :model)
    end

    def controller(src, options = {})
      file(src, options, :controller)
    end

    def view(src, options = {})
      file(src, options, :view)
    end

    def layout(src, options = {})
      file(src, options, :layout)
    end

    def base_url(path)
      self.class.base_url = path
    end

    def blog_post(url)
      self.class.blog_post = url
    end

    protected

    def join_with_parent(parent_value, new_value)
      if parent_value && new_value
        File.join(parent_value, new_value)
      else
        parent_value || new_value
      end
    end

    def options_relative_to_parent(parent_options, options)
      {
        :src  => join_with_parent(parent_options[:src],  options[:src]),
        :dest => join_with_parent(parent_options[:dest], options[:dest])
      }
    end
  end
end
