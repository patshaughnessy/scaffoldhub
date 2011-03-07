require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Scaffoldhub::ScaffoldSpec do

  before do
    @status_proc = mock
    @status_proc.stubs(:call)
  end

  describe 'parsing scaffold spec' do

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

      subject do
        Scaffoldhub::ScaffoldSpec.new('http://fake.scaffoldhub.org:1234/scaffolds/autocomplete/spec', false, @status_proc)
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

  describe '#select_files' do

    subject do
      Scaffoldhub::ScaffoldSpec.new('unused', true, @status_proc)
    end

    before do
      subject.stubs(:template_file_specs).returns([
        { :type => 'type1', :src => 'some_src',  :dest => 'some_dest' },
        { :type => 'type1', :src => 'some_src2', :dest => 'some_dest' },
        { :type => 'type1', :src => 'some_src3', :dest => 'some_dest' },
        { :type => 'type2', :src => 'some_src4', :dest => 'some_dest' }
      ])
    end

    it 'should select the files with the given type' do
      Scaffoldhub::TemplateFile.expects(:new).returns(mock1 = mock)
      Scaffoldhub::TemplateFile.expects(:new).returns(mock2 = mock)
      Scaffoldhub::TemplateFile.expects(:new).returns(mock3 = mock)
      files = subject.select_files('type1')
      files.include?(mock1).should be_true
      files.include?(mock2).should be_true
      files.include?(mock3).should be_true
    end
  end

  describe '#find_file' do

    subject do
      Scaffoldhub::ScaffoldSpec.new('unused', true, @status_proc)
    end

    before do
      subject.stubs(:template_file_specs).returns([
        { :type => 'type1', :src => 'some_src',  :dest => 'some_dest' },
        { :type => 'type1', :src => 'some_src2', :dest => 'some_dest' },
        { :type => 'type1', :src => 'some_src3', :dest => 'some_dest' },
        { :type => 'type2', :src => 'some_src4', :dest => 'some_dest' }
      ])
      subject.stubs(:base_url).returns('base')
    end

    it 'should find the file with the given type and src' do
      Scaffoldhub::TemplateFile.expects(:new).with('some_src2', 'some_dest', true, 'base', @status_proc).returns(mock1 = mock)
      subject.find_file('type1', 'some_src2').should == mock1
    end

    it 'should return nil if the name is not found' do
      Scaffoldhub::TemplateFile.expects(:new).never
      subject.find_file('type1', 'some_src5').should be_nil
    end

    it 'should return nil if the type is not found' do
      Scaffoldhub::TemplateFile.expects(:new).never
      subject.find_file('type3', 'some_src2').should be_nil
    end
  end
end
