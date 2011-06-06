require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Scaffoldhub::Runner do

  describe 'push valid spec' do
    before do
      @test_scaffold = File.join(File.dirname(__FILE__), 'fixtures', 'test_scaffold.rb')
      Scaffoldhub::Specification.stubs(:valid?).returns(true)
      subject.expects(:post_spec).with(@test_scaffold)
    end
    it 'should post a valid spec' do
      subject.push(@test_scaffold)
    end
  end

  describe 'push invalid spec' do
    before do
      @test_scaffold = File.join(File.dirname(__FILE__), 'fixtures', 'test_scaffold.rb')
      Scaffoldhub::Specification.stubs(:valid?).returns(false)
      Scaffoldhub::Specification.stubs(:errors).returns(['error one', 'error two'])
      subject.expects(:post_spec).never
      subject.expects(:say).with("Unable to post your new scaffold. Please resolve these errors:")
      subject.expects(:say).with("error one")
      subject.expects(:say).with("error two")
    end
    it 'should post a valid spec' do
      subject.push(@test_scaffold)
    end
  end

  describe 'push missing spec' do
    before do
      @test_scaffold = '/invalid/path'
      Scaffoldhub::Specification.expects(:valid?).never
      subject.stubs(:say)
    end
    it 'should not post an invalid spec' do
      subject.push(@test_scaffold)
    end
  end

  describe 'run scaffold via method missing' do
    before do
      subject.expects(:system).with("rails generate scaffoldhub person name:string --scaffold some_scaffold")
    end
    it 'should shell out to the specified scaffold' do
      subject.some_scaffold 'person', 'name:string'
    end
  end

  describe 'run scaffold with a scaffold parameter via method missing' do
    before do
      subject.expects(:system).with("rails generate scaffoldhub person name:string --scaffold some_scaffold:some_field")
    end
    it 'should shell out to the specified scaffold' do
      subject.send 'some_scaffold:some_field'.to_sym, 'person', 'name:string'
    end
  end

  describe '#post_spec' do
    before do
      Scaffoldhub::Runner.class_eval { public :post_spec }
      subject.expects(:load_config).returns({:username => 'user', :password => 'pass'})
      URI.expects(:parse).with("http://www.scaffoldhub.org/admin/scaffolds").returns(url = mock)
      url.expects(:path).returns('/admin/scaffolds')
      Net::HTTP::Post.expects(:new).with('/admin/scaffolds').returns(post = mock)
      post.expects(:basic_auth).with('user', 'pass')
      Scaffoldhub::Specification.expects(:to_yaml).returns('yaml')
      post.expects(:set_form_data).with(
        {
          'scaffold'       => 'yaml',
          'spec_file_name' => 'some_scaffold.rb'
        },
        ';'
      )
      url.expects(:host).returns('www.scaffoldhub.org')
      url.expects(:port).returns(80)
      Net::HTTP.expects(:new).with('www.scaffoldhub.org', 80).returns(http = mock)
      http.expects(:start).returns(response = mock)
      response.expects(:body).twice.returns('New scaffold created.')
      subject.expects(:save_config).with('user', 'pass')
      subject.expects(:say).with('New scaffold created.')
    end
    after do
      Scaffoldhub::Runner.class_eval { private :post_spec }
    end
    it 'should post a scaffold to the server' do
      subject.post_spec('/path/to/some_scaffold.rb')
    end
  end
end
