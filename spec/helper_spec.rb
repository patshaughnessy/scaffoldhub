require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class FakeGenerator

  class << self
    def source_root(value)
      @sr = value
    end
    def source_root_value
      @sr
    end
  end

  include Scaffoldhub::Helper

  attr_accessor :files

  def initialize(local, options = 'some_scaffold:some_parameter')
    @files   = []
    @local   = local
    @options = options
  end

  def copy_files
    each_template_file(:sometype) do |template_file|
      files << template_file
    end
  end

  def options
    { :scaffold => @options, :local => @local }
  end
end

describe Scaffoldhub::Helper do

  describe 'local scaffold' do

    before(:all) do
      Scaffoldhub::Helper.scaffold_spec = nil
      status_proc = mock
      status_proc.stubs(:call)
      mock_spec = mock
      Scaffoldhub::ScaffoldSpec.stubs(:new).with('some_scaffold', true, status_proc).returns(mock_spec)
      mock_spec.stubs(:download_and_parse!)
      mock_spec.stubs(:parameter_example)
      mock_template_file_array = [
        Scaffoldhub::TemplateFile.new('src1', 'dest1', nil, true, '/some/path', status_proc),
        Scaffoldhub::TemplateFile.new('src2', 'dest2', nil, true, '/some/path', status_proc),
        Scaffoldhub::TemplateFile.new('src3', 'dest3', nil, true, '/some/path', status_proc)
      ]
      mock_spec.stubs(:select_files).with(:sometype).returns(mock_template_file_array)
      @gen = FakeGenerator.new(true)
      @gen.stubs(:status_proc).returns(status_proc)
    end

    it 'should yield the template files' do
      File.expects(:exists?).with('/some/path/src1').returns(true)
      File.expects(:exists?).with('/some/path/src2').returns(true)
      File.expects(:exists?).with('/some/path/src3').returns(true)
      @gen.copy_files
      @gen.files[0].src.should == '/some/path/src1'
      @gen.files[1].src.should == '/some/path/src2'
      @gen.files[2].src.should == '/some/path/src3'
    end

    it 'should raise an exception if the template file doesn\'t exist' do
      File.expects(:exists?).with('/some/path/src1').returns(false)
      @gen.expects(:say_status).with(:error, 'No such file or directory - /some/path/src1', :red)
      lambda { @gen.copy_files }.should raise_error(Errno::ENOENT)
    end
  end

  describe 'remote scaffold' do

    before do
      Scaffoldhub::Helper.scaffold_spec = nil
      status_proc = mock
      status_proc.stubs(:call)
      mock_spec = mock
      Scaffoldhub::ScaffoldSpec.stubs(:new).with('some_scaffold', false, status_proc).returns(mock_spec)
      mock_spec.stubs(:download_and_parse!)
      mock_spec.stubs(:parameter_example)
      template1 = Scaffoldhub::TemplateFile.new('src1', 'dest1', nil, false, 'http://some.server/some/path', status_proc)
      template1.expects(:download!).returns(template1)
      template1.stubs(:src).returns('src1')
      template2 = Scaffoldhub::TemplateFile.new('src2', 'dest2', nil, false, 'http://some.server/some/path', status_proc)
      template2.expects(:download!).returns(template2)
      template2.stubs(:src).returns('src2')
      template3 = Scaffoldhub::TemplateFile.new('src3', 'dest3', nil, false, 'http://some.server/some/path', status_proc)
      template3.expects(:download!).returns(template3)
      template3.stubs(:src).returns('src3')
      mock_template_file_array = [ template1, template2, template3 ]
      mock_spec.stubs(:select_files).with(:sometype).returns(mock_template_file_array)
      @gen = FakeGenerator.new(false)
      @gen.stubs(:status_proc).returns(status_proc)
    end

    it 'should yield the template files' do
      @gen.copy_files
      @gen.files[0].src.should == 'src1'
      @gen.files[1].src.should == 'src2'
      @gen.files[2].src.should == 'src3'
    end
  end

  describe 'sharing scaffold spec among generators' do

    before do
      Scaffoldhub::Helper.scaffold_spec = nil
      @mock_spec = mock
      @mock_spec.stubs(:download_and_parse!)
      @mock_spec.stubs(:parameter_example)
      status_proc = mock
      Scaffoldhub::ScaffoldSpec.expects(:new).once.with('some_scaffold', false, status_proc).returns(@mock_spec)
      @gen =  FakeGenerator.new(false)
      @gen.stubs(:status_proc).returns(status_proc)
      @gen2 = FakeGenerator.new(false)
      @gen2.stubs(:status_proc).returns(status_proc)
    end

    it 'should save the scaffold spec in the module among different generators' do
      @gen.scaffold_spec.should  == @mock_spec
      @gen2.scaffold_spec.should == @mock_spec
    end
  end

  describe '#find_template_file' do

    it 'should call find_file on the scaffold spec' do
      gen = FakeGenerator.new(false)
      gen.expects(:find_file).with('type', 'name')
      gen.find_file('type', 'name')
    end
  end

  describe '#scaffold_name' do

    describe 'both values present' do
      subject { FakeGenerator.new(false) }
      its(:scaffold_name)      { should == 'some_scaffold' }
      its(:scaffold_parameter) { should == 'some_parameter' }
    end

    describe 'only scaffold name present' do
      subject { FakeGenerator.new(false, 'scaffold_name_only') }
      its(:scaffold_name)      { should == 'scaffold_name_only' }
      its(:scaffold_parameter) { should == nil }
    end

  end

  describe '#replace_name_tokens' do
    subject { FakeGenerator.new(false) }
    before do
      subject.expects(:scaffold_parameter).twice.returns('some_field')
      subject.expects(:file_name).returns('person')
      subject.expects(:file_name).returns(name = mock)
      name.stubs(:pluralize).returns('people')
    end
    it 'should replace the NAME token' do
      subject.replace_name_tokens('_NAME.html.erb').should == '_person.html.erb'
    end
    it 'should replace the PLURAL_NAME token' do
      subject.replace_name_tokens('PLURAL_NAME.html.erb').should == 'people.html.erb'
    end
    it 'should replace the SCAFFOLD_PARAMETER token' do
      subject.replace_name_tokens('blah blah SCAFFOLD_PARAMETER blah blah blah').should == 'blah blah some_field blah blah blah'
    end
  end

  describe 'calling source root' do
    it 'should call source_root when included in each generator class' do
      FakeGenerator.source_root_value.should == Dir.tmpdir
    end
  end
end
