require 'yaml'

module Scaffoldhub
  class Specification

    @@files  = []
    @@base_url = nil
    @@name = nil
    @@description = nil
    @@screenshot = nil
    @@errors  = []

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

      def name
        @@name
      end

      def name=(name)
        @@name = name
      end

      def description
        @@description
      end

      def description=(desc)
        @@description = desc
      end

      def screenshot
        @@screenshot
      end

      def screenshot=(desc)
        @@screenshot = desc
      end

      def errors
        @@errors
      end

      def errors=(array)
        @@errors = array
      end

      def to_yaml
        {
          :base_url    => base_url,
          :blog_post   => blog_post,
          :files       => files,
          :name        => name,
          :description => description,
          :screenshot  => screenshot
        }.to_yaml
      end

      def valid?
        has_name? && has_description? && has_base_url? && has_screenshot? && all_template_files_exist?
      end

      def has_name?
        has_string_value?(:name)
      end

      def has_description?
        has_string_value?(:description)
      end

      def has_base_url?
        has_string_value?(:base_url)
      end

      def has_string_value?(value)
        val = send(value)
        valid = (val && val != '')
        errors.push("Error: missing scaffold #{value}.") unless valid
        valid
      end
      
      def has_screenshot?
        has_string_value?(:screenshot) && remote_file_exists?(File.join(base_url, screenshot))
      end

      def all_template_files_exist?
        files.all? { |file| remote_file_exists?(File.join(base_url, file[:src])) }
      end

      def remote_file_exists?(url)
        puts "DEBUG remote file exists? #{url}"
        valid = RemoteFile.new(url).exists?
        puts "DEBUG valid #{valid.inspect}"
        errors.push("Error: unable to access remote URL #{url}") unless valid
        valid
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

    def name(name)
      self.class.name = name
    end

    def description(desc)
      self.class.description = desc
    end

    def screenshot(path)
      self.class.screenshot = path
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
