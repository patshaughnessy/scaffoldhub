require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Net
  class HTTP

    def self.set_mock_http(mock_http)
      @mock_http = mock_http
    end

    def self.start(host, port)
      yield @mock_http
    end
  end
end

describe Scaffoldhub::RemoteFile do

  FAKE_SCAFFOLDHUB_URL = 'http://fake.scaffoldhub.org:1234/scaffolds/autocomplete/spec'

  describe '#remote_file_contents' do

    describe 'status proc' do
      subject do
        @status_proc = mock
        @status_proc.expects(:call).with(FAKE_SCAFFOLDHUB_URL)
        Scaffoldhub::RemoteFile.new(@status_proc)
      end
      before do
        subject.stubs(:url).returns(FAKE_SCAFFOLDHUB_URL)
      end

      it 'should call the status proc with the url' do
        Net::HTTP.stubs(:start)
        subject.remote_file_contents!
      end
    end

    describe 'Net:HTTP calls' do

      subject do
        (status_proc = mock).stubs(:call).with(FAKE_SCAFFOLDHUB_URL)
        Scaffoldhub::RemoteFile.new(status_proc)
      end
      before do
        subject.stubs(:url).returns(FAKE_SCAFFOLDHUB_URL)
      end

      it 'should call Net::HTTP with the proper host and port' do
        Net::HTTP.expects(:start).with('fake.scaffoldhub.org', 1234)
        subject.remote_file_contents!
      end

      it 'should call GET on the url path and return the response body' do
        mock_http = mock
        mock_http.expects(:get).with('/scaffolds/autocomplete/spec').returns(mock_response = mock)
        mock_response.stubs(:code).returns(200)
        mock_response.stubs(:body).returns('RESPONSE')
        Net::HTTP.set_mock_http(mock_http)
        subject.remote_file_contents!.should == 'RESPONSE'
      end

      it 'should throw a NotFoundException on 404' do
        mock_http = mock
        mock_http.expects(:get).with('/scaffolds/autocomplete/spec').returns(mock_response = mock)
        mock_response.stubs(:code).returns(404)
        Net::HTTP.set_mock_http(mock_http)
        lambda { subject.remote_file_contents! }.should raise_error(Scaffoldhub::NotFoundException)
      end

      it 'should throw a NetworkErrorException on some other error' do
        mock_http = mock
        mock_http.expects(:get).with('/scaffolds/autocomplete/spec').raises(Errno::ECONNREFUSED)
        Net::HTTP.set_mock_http(mock_http)
        lambda { subject.remote_file_contents! }.should raise_error(Scaffoldhub::NetworkErrorException)
      end
    end

  end
end
