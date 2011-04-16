require 'net/http'
require 'uri'
require 'yaml'
require 'thor'

module Scaffoldhub
  class Runner < Thor
    desc "push /path/to/scaffold_spec.rb", "Compile specified scaffold spec and push it to scaffold.org"
    def push(scaffold_spec)
      if load_spec(scaffold_spec)
        if Specification.valid?
          post_spec
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

    def post_spec
      #username = ask 'Username:'
      #password = ask 'Password:'
      #say "Username: #{username} password: #{password}"
      #
      #
      #

      url = URI.parse('http://localhost:3000/admin/scaffolds')
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth 'Pat Shaughnessy', 'sihaya'
      req.set_form_data({'scaffold' => Specification.to_yaml}, ';')
      response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      say response.body
    end

  end
end
