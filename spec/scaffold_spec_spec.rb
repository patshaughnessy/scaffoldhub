require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Scaffoldhub::ScaffoldSpec do

  before do
    @status_proc = mock
    @status_proc.stubs(:call)
  end

  describe 'parsing local scaffold spec' do

    subject do
      test_spec_path = File.join(File.dirname(__FILE__), 'fixtures', 'test_scaffoldspec.rb')
      Scaffoldhub::ScaffoldSpec.new(test_spec_path, true, @status_proc)
    end

    before do
      Scaffoldhub::Specification.files = []
      Scaffoldhub::Specification.base_url = nil
    end

    it 'should require a local scaffold spec and parse the file list' do
      subject.download_and_parse!
      subject.template_file_specs.should == [
        { :type => 'erb',        :src => 'templates/index3.html.erb', :dest => '' },
        { :type => 'controller', :src => 'templates/index2.html.erb', :dest => '' },
        { :type => 'other',      :src => 'templates/index.html.erb',  :dest => 'app/views/welcome' }
      ]
      subject.base_url.should == File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))
    end
  end

  describe 'parsing remote scaffold spec' do

    TEST_YAML = <<YAML
--- 
:base_url: http://github.com/patshaughnessy/scaffolds/default
:files: 
- :src: templates/index3.html.erb
  :dest: 
  :type: erb
- :src: templates/index2.html.erb
  :dest: 
  :type: controller
- :src: templates/index.html.erb
  :dest: app/views/welcome
  :type: other
YAML

    FAKE_SCAFFOLDHUB_URL = 'http://fake.scaffoldhub.org:1234/scaffolds/autocomplete/spec'

    subject do
      Scaffoldhub::ScaffoldSpec.new(FAKE_SCAFFOLDHUB_URL, false, @status_proc)
    end

    before do
      Scaffoldhub::Specification.files = []
      Scaffoldhub::Specification.base_url = nil
      subject.expects(:remote_file_contents!).returns(TEST_YAML)
    end

    it 'should require a local scaffold spec' do
      subject.download_and_parse!
      subject.template_file_specs.should == [
        { :type => 'erb',        :src => 'templates/index3.html.erb', :dest => nil },
        { :type => 'controller', :src => 'templates/index2.html.erb', :dest => nil },
        { :type => 'other',      :src => 'templates/index.html.erb',  :dest => 'app/views/welcome' }
      ]
      subject.base_url.should == 'http://github.com/patshaughnessy/scaffolds/default'
    end
  end

end
