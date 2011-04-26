require 'yaml'

def mattr_reader(*syms)
  syms.each do |sym|
    class_eval(<<-EOS, __FILE__, __LINE__)
      @@#{sym} = nil

      def self.#{sym}
        @@#{sym}
      end

      def self.#{sym}=(obj)
        @@#{sym} = obj
      end
    EOS
  end
end

def define_dsl_attributes(*syms)
  syms.each do |sym|
    class_eval(<<-EOS, __FILE__, __LINE__)
      def #{sym}(val)
        self.class.#{sym} = val
      end
    EOS
  end
end

def define_dsl_file_keyword(*syms)
  syms.each do |sym|
    class_eval(<<-EOS, __FILE__, __LINE__)
      def #{sym}(src, options = {})
        file(src, options, :#{sym})
      end
    EOS
  end
end

module Scaffoldhub
  class Specification

    mattr_reader          :name, :description, :base_url, :blog_post, :screenshot, :parameter_example
    define_dsl_attributes :name, :description, :base_url, :blog_post, :screenshot, :parameter_example

    mattr_reader :files, :errors, :tags
    @@files  = []
    @@errors = []
    @@tags   = []

    define_dsl_file_keyword :model, :migration, :controller, :view, :layout

    class << self

      def add_file(src, dest, type)
        @@files << { :type => type, :src => src, :dest => dest }
      end

      def add_tag(keyword)
        @@tags << keyword
      end

      def to_yaml
        {
          :name        => name,
          :description => description,
          :base_url    => base_url,
          :blog_post   => blog_post,
          :files       => files,
          :screenshot  => screenshot,
          :parameter_example => parameter_example,
          :tags        => tags
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
        valid = RemoteFile.new(url).exists?
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

    def metadata
      yield if block_given?
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

    def tag(keyword)
      self.class.add_tag(keyword)
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
