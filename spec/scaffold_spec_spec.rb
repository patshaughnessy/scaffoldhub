require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def find_spec(scaffold_spec, type, src)
  find_spec_in_array(scaffold_spec.template_file_specs, type, src)
end

def find_spec_in_array(array, type, src)
  array.detect { |spec| spec[:type] == type && spec[:src] == src }
end

describe Scaffoldhub::ScaffoldSpec do

  before do
    @status_proc = mock
    @status_proc.stubs(:call)
  end

  describe 'parsing scaffold spec' do

    describe 'parsing local scaffold spec' do

      subject do
        test_spec_path = File.join(File.dirname(__FILE__), 'fixtures', 'test_scaffold.rb')
        scaffold = Scaffoldhub::ScaffoldSpec.new(test_spec_path, true, @status_proc)
        scaffold.download_and_parse!
        scaffold
      end

      it 'should set the base_url to the scaffold specs folder' do
        subject.base_url.should == File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))
      end

      it 'should parse the blog_post' do
        subject.blog_post.should == 'http://patshaughnessy.net/2011/3/13/view-mapper-for-rails-3-scaffoldhub'
      end

      it 'should parse the model file' do
        model_spec = subject.template_file_specs.detect { |spec| spec[:type] == :model }
        find_spec(subject, :model, 'templates/model.rb').should_not be_nil
      end

      it 'should parse the controller file' do
        find_spec(subject, :controller, 'templates/controller.rb').should_not be_nil
      end

      it 'should parse a view file' do
        find_spec(subject, :view, 'templates/_form.html.erb').should_not be_nil
      end

      it 'should parse a layout file' do
        find_spec(subject, :layout, 'templates/layout.erb').should_not be_nil
      end

      it 'should parse with_options and use :src as a folder for the given file' do
        find_spec(subject, :view, 'templates/new.html.erb').should_not be_nil
        find_spec(subject, :view, 'templates/edit.html.erb').should_not be_nil
        find_spec(subject, :view, 'templates/index.html.erb').should_not be_nil
        find_spec(subject, :view, 'templates/show.html.erb').should_not be_nil
      end

      it 'should parse a vanilla template file with a dest attribute' do
        template_spec = find_spec(subject, :template, 'templates/other_code_file.erb')
        template_spec.should_not be_nil
        template_spec[:dest].should == 'lib/other_code_file.rb'
      end

      it 'should parse a normal file with a dest attribute' do
        template_spec = find_spec(subject, :file, 'templates/jquery/jquery-1.4.4.min.js')
        file_spec = subject.template_file_specs.detect { |spec| spec[:type] == :file }
        file_spec.should_not be_nil
        file_spec[:dest].should == 'public/javascripts'
      end

      it 'should recursively parse with_options' do
        template_spec1 = find_spec(subject, :file, 'templates/jquery/jquery-ui-1.8.10.custom.min.js')
        template_spec1.should_not be_nil
        template_spec1[:dest].should == 'public/javascripts'
        template_spec2 = find_spec(subject, :file, 'templates/jquery/ui-lightness/jquery-ui-1.8.10.custom.css')
        template_spec2.should_not be_nil
        template_spec2[:dest].should == 'public/javascripts/ui-lightness'
        template_spec3 = find_spec(subject, :file, 'templates/jquery/ui-lightness/images/ui-bg_diagonals-thick_18_b81900_40x40.png')
        template_spec3.should_not be_nil
        template_spec3[:dest].should == 'public/javascripts/ui-lightness/images'
        template_spec4 = find_spec(subject, :file, 'templates/jquery/ui-lightness/images/ui-icons_ffffff_256x240.png')
        template_spec4.should_not be_nil
        template_spec4[:dest].should == 'public/javascripts/ui-lightness/images'
      end
    end


    describe 'parsing remote scaffold spec' do

      before do
        Scaffoldhub::Specification.files = []
        Scaffoldhub::Specification.base_url = nil
      end

      TEST_YAML = <<YAML
  --- 
  :base_url: http://github.com/patshaughnessy/scaffolds/default
  :files: 
  - :src: templates/index3.html.erb
    :dest: 
    :type: view
  - :src: templates/index2.html.erb
    :dest: 
    :type: controller
  - :src: templates/index.html.erb
    :dest: app/views/welcome
    :type: file
YAML

      subject do
        Scaffoldhub::ScaffoldSpec.new('http://fake.scaffoldhub.org:1234/scaffolds/autocomplete/spec', false, @status_proc)
      end

      before do
        Scaffoldhub::Specification.files = []
        Scaffoldhub::Specification.base_url = nil
        subject.expects(:remote_file_contents!).returns(TEST_YAML)
      end

      it 'should parse a remote yaml scaffold' do
        subject.download_and_parse!
        subject.template_file_specs.should == [
          { :type => 'view',       :src => 'templates/index3.html.erb', :dest => nil },
          { :type => 'controller', :src => 'templates/index2.html.erb', :dest => nil },
          { :type => 'file',       :src => 'templates/index.html.erb',  :dest => 'app/views/welcome' }
        ]
        subject.base_url.should == 'http://github.com/patshaughnessy/scaffolds/default'
      end
    end
  end

  describe 'generating yaml' do

    subject do
      test_spec_path = File.join(File.dirname(__FILE__), 'fixtures', 'test_scaffold.rb')
      scaffold = Scaffoldhub::ScaffoldSpec.new(test_spec_path, true, @status_proc)
      scaffold.download_and_parse!
      scaffold
    end

    it 'should generate yaml from a scaffold spec' do
      yaml = subject.to_yaml
      parsed_yaml = YAML::load(yaml)
      parsed_yaml[:base_url].should  == 'https://github.com/patshaughnessy/scaffolds/tree/master/default'
      parsed_yaml[:blog_post].should == 'http://patshaughnessy.net/2011/3/13/view-mapper-for-rails-3-scaffoldhub'
      model_spec = find_spec_in_array(parsed_yaml[:files], :model, 'templates/model.rb')
      model_spec.should_not be_nil
      some_file_spec = find_spec_in_array(parsed_yaml[:files], :file, 'templates/jquery/ui-lightness/images/ui-bg_diagonals-thick_20_666666_40x40.png')
      some_file_spec.should_not be_nil
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
