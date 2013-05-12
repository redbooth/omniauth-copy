require 'spec_helper'

describe OmniAuth::Strategies::Copy do
  let(:access_token) { stub('AccessToken', :options => {}) }
  let(:parsed_response) { stub('ParsedResponse') }
  let(:response) { stub('Response', :parsed => parsed_response) }

  subject do
    OmniAuth::Strategies::Copy.new({})
  end

  before(:each) do
    subject.stub!(:access_token).and_return(access_token)
  end

  context "client options" do
    it 'should have correct site' do
      subject.options.client_options.site.should eq('https://api.copy.com')
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('https://www.copy.com/applications/authorize')
    end

    it 'should have correct request token url' do
      subject.options.client_options.request_token_url.should eq('https://api.copy.com/oauth/request')
    end

    it 'should have correct access token url' do
      subject.options.client_options.access_token_url.should eq('https://api.copy.com/oauth/access')
    end
  end

end
