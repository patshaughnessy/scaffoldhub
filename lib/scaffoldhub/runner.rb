require 'net/http'
require 'uri'
require 'yaml'
require 'thor'

module Scaffoldhub
  class Runner < Thor
    desc "push /path/to/scaffold_spec.rb", "Compile specified scaffold spec and push it to scaffoldhub.org"
    def push(scaffold_spec)
      if load_spec(scaffold_spec)
        if Specification.valid?
          post_spec(scaffold_spec)
        else
          say "Unable to post your new scaffold. Please resolve these errors:"
          Specification.errors.each { |error| say error }
        end
      end
    end

    private

    def load_spec(scaffold_spec)
      begin
        require scaffold_spec
        true
      rescue Exception => e
        say "There was an error parsing your scaffold spec file."
        say e.message
        say e.backtrace[0]
        false
      end
    end

    def post_spec(scaffold_spec)

      begin
        config = load_config
        username = config[:username]
        password = config[:password]
      rescue
        say "Please enter your scaffoldhub.org credentials..."
        username = ask "Username: "
        password = ask "Password: "
      end

      url = URI.parse("http://#{SCAFFOLD_HUB_SERVER}/admin/scaffolds")
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth username, password
      req.set_form_data({'scaffold' => Specification.to_yaml, 'spec_file_name' => File.basename(scaffold_spec) }, ';')
      response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      say response.body
      save_config(username, password) unless response.body == 'Invalid username or password.'
    end

    def config_file
      File.join(find_home, '.scaffoldhub')
    end

    def load_config
      YAML::load(File.read(config_file))
    end

    def save_config(username, password)
      File.open(config_file, 'w') {|f| f.write({ :username => username, :password => password }.to_yaml) }
    end

    # Ripped from rubygems
    def find_home
      unless RUBY_VERSION > '1.9' then
        ['HOME', 'USERPROFILE'].each do |homekey|
          return File.expand_path(ENV[homekey]) if ENV[homekey]
        end

        if ENV['HOMEDRIVE'] && ENV['HOMEPATH'] then
          return File.expand_path("#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}")
        end
      end

      File.expand_path "~"
    rescue
      if File::ALT_SEPARATOR then
        drive = ENV['HOMEDRIVE'] || ENV['SystemDrive']
        File.join(drive.to_s, '/')
      else
        "/"
      end
    end

  end
end
