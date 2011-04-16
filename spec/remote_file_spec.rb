require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MockHTTP

  def self.set_mock_http(mock_http)
    @mock_http = mock_http
  end

  def start
    yield self
  end
end

describe Scaffoldhub::RemoteFile do

  FAKE_SCAFFOLDHUB_URL = 'http://fake.scaffoldhub.org:1234/scaffolds/autocomplete/spec'
  FAKE_GITHUB_URL = 'https://fake.github.com/patshaughnessy/scaffolds'

  describe '#remote_file_contents' do

    describe 'status proc' do
      subject do
        @status_proc = mock
        @status_proc.expects(:call).with(FAKE_SCAFFOLDHUB_URL)
        Scaffoldhub::RemoteFile.new(FAKE_SCAFFOLDHUB_URL, @status_proc)
      end
      it 'should call the status proc with the url' do
        Net::HTTP.stubs(:new).returns(http = mock)
        http.stubs(:start).returns(response = mock)
        response.stubs(:code).returns(200)
        response.stubs(:body).returns('')
        subject.remote_file_contents!
      end
    end

    describe 'Net:HTTP calls' do

      subject do
        (status_proc = mock).stubs(:call).with(FAKE_SCAFFOLDHUB_URL)
        Scaffoldhub::RemoteFile.new(FAKE_SCAFFOLDHUB_URL, status_proc)
      end

      it 'should call Net::HTTP with the proper host and port' do
        Net::HTTP.expects(:new).with('fake.scaffoldhub.org', 1234).returns(http = mock)
        http.stubs(:start).returns(response = mock)
        response.stubs(:code).returns(200)
        response.stubs(:body).returns('')
        subject.remote_file_contents!
      end

      it 'should call GET on the url path and return the response body' do
        Net::HTTP.stubs(:new).returns(mock_http = MockHTTP.new)
        mock_http.expects(:get).with('/scaffolds/autocomplete/spec').returns(response = mock)
        response.stubs(:code).returns(200)
        response.stubs(:body).returns('RESPONSE')
        subject.remote_file_contents!.should == 'RESPONSE'
      end

      it 'should throw a NotFoundException on 404' do
        Net::HTTP.stubs(:new).returns(mock_http = MockHTTP.new)
        mock_http.expects(:get).returns(response = mock)
        response.stubs(:code).returns(404)
        lambda { subject.remote_file_contents! }.should raise_error(Scaffoldhub::NotFoundException)
      end

      it 'should throw a NetworkErrorException on some other error' do
        Net::HTTP.stubs(:new).returns(mock_http = MockHTTP.new)
        mock_http.expects(:get).raises(Errno::ECONNREFUSED)
        lambda { subject.remote_file_contents! }.should raise_error(Scaffoldhub::NetworkErrorException)
      end
    end

    describe 'Net:HTTP SSL calls' do
      subject do
        (status_proc = mock).stubs(:call).with(FAKE_GITHUB_URL)
        Scaffoldhub::RemoteFile.new(FAKE_GITHUB_URL, status_proc)
      end
      it 'should call Net::HTTP with the proper SSL options' do
        Net::HTTP.expects(:new).with('fake.github.com', 443).returns(http = mock)
        http.expects(:use_ssl=).with(true)
        http.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
        http.stubs(:start).returns(response = mock)
        response.stubs(:code).returns(200)
        response.stubs(:body).returns('')
        subject.remote_file_contents!
      end
    end

  end
end
