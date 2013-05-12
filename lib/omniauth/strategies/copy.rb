require 'omniauth-oauth'

module OmniAuth
  module Strategies
    class Copy < OmniAuth::Strategies::OAuth
      option :name, 'copy'
      option :client_options, {
        :site => 'http://api.copy.com',
        :authorize_url => 'http://www.copy.com/applications/authorize',
        :request_token_url => 'http://api.copy.com/oauth/request',
        :access_token_url => 'http://api.copy.com/oauth/access'
      }
      option :request_params, {
        :scope => '{"profile":{"read":true,"email":{"read":true}}}'
      }

      uid { raw_info['id'] }

      info do
        primary_email = raw_info['email']
        unless primary_email
          raw_info['emails'].each do |email|
            primary_email = email['email'] if email['primary']
            break
          end
        end

        {
          'uid'   => raw_info['id'],
          'name'  => "#{raw_info['first_name']} #{raw_info['last_name']}",
          'email' => primary_email,
          'first_name' => raw_info['first_name'],
          'last_name' => raw_info['last_name']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('/rest/user', :parse => :json).parsed
      end
    end
  end
end
