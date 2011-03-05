require 'tempfile'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Scaffoldhub::TemplateFile do

  before do
    @status_proc = mock
    @status_proc.stubs(:call)
  end

  describe 'local template file' do

    subject { Scaffoldhub::TemplateFile.new('/templates/index.html', 'public', true, File.expand_path(File.dirname(__FILE__)), @status_proc) }

    its(:src)  { should == File.expand_path(File.join(File.dirname(__FILE__), 'templates', 'index.html')) }
    its(:url)  { should == File.expand_path(File.join(File.dirname(__FILE__), 'templates', 'index.html')) }
    its(:dest) { should == File.join('public', 'index.html') }
  end

  describe 'remote template file' do

    FAKE_GITHUB_URL = 'http://github.com/patshaughnessy/scaffolds/default'

    subject { Scaffoldhub::TemplateFile.new('/templates/index.html', 'public', false, FAKE_GITHUB_URL, @status_proc) }

    its(:url)  { should == FAKE_GITHUB_URL + '/templates/index.html' }
    its(:dest) { should == File.join('public', 'index.html') }

    describe '#download!' do

      before do
        @local_path = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'local_template_file.txt'))
        File.delete(@local_path) if File.exists?(@local_path)
        subject.stubs(:remote_file_contents!).returns('TEMPLATE')
        tempfile = mock
        Tempfile.stubs(:new).returns(tempfile)
        tempfile.stubs(:path).returns(@local_path)
        subject.download!
      end

      it 'should set the src to the local path after a download' do
        subject.src.should == @local_path
      end

      it 'should write the template file contents into a local file' do
        File.new(@local_path).read.should == 'TEMPLATE'
      end
    end
  end
end
