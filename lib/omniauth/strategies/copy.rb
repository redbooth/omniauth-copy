require 'omniauth-oauth'

# Copy doesn't follow the spec and uses oauth_callback_confirmed=1 instead of true. Sigh.
# Replace the method that looks at that parameter in the OAuth library.
module OAuth
  class RequestToken < ConsumerToken
    def callback_confirmed?
      params[:oauth_callback_confirmed] == "true" || params[:oauth_callback_confirmed] == "1"
    end
  end
end

module OmniAuth
  module Strategies
    class Copy < OmniAuth::Strategies::OAuth
      option :name, 'copy'
      option :client_options, {
        :site => 'https://api.copy.com',
        :authorize_url => 'https://www.copy.com/applications/authorize',
        :request_token_url => 'https://api.copy.com/oauth/request',
        :access_token_url => 'https://api.copy.com/oauth/access',
        :http_method => :get
      }
      option :scope, '{"profile":{"read":true,"email":{"read":true}}}'

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
        @raw_info ||= MultiJson.decode(access_token.get('/rest/user', {'X-API-Version' => '1.0', 'Accept' => 'application/json'}).body)
      end

      # We need a custom request_phase because Copy requires that the oauth_callback and scope
      # parameters be query strings args, not in the Authorization header. And there's no clean way
      # to do that, so we'll basically copy the standard request_phase and tweak the get_request_token
      # call so it doesn't include the callback. Our URL will already include the callback.
      def request_phase
        request_token = consumer.get_request_token({:exclude_callback => true}, options.request_params)
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => request_token.callback_confirmed?, 'request_token' => request_token.token, 'request_secret' => request_token.secret}

        if request_token.callback_confirmed?
          redirect request_token.authorize_url(options[:authorize_params])
        else
          redirect request_token.authorize_url(options[:authorize_params].merge(:oauth_callback => callback_url))
        end

      rescue ::Timeout::Error => e
        fail!(:timeout, e)
      rescue ::Net::HTTPFatalError, ::OpenSSL::SSL::SSLError => e
        fail!(:service_unavailable, e)
      end

      # Dirty hacks to work with Copy. Copy requires that certain parameters be in the query string
      # and not in the Authorization header, but OmniAuth/OAuth want them to be in the header. So
      # we intercept the consumer construction and tweak our URLs so that they include whatever
      # parameters they need to. For the oauth_verifier, we need to go even further and remove the
      # arg from the request so that it doesn't get added twice.
      def consumer
        options.client_options[:request_token_url] = "https://api.copy.com/oauth/request?oauth_callback=#{URI.escape(callback_url)}&scope=#{URI.escape(options.scope)}"
        if request['oauth_verifier']
          options.client_options[:access_token_url] = "https://api.copy.com/oauth/access?oauth_verifier=#{URI.escape(request['oauth_verifier'])}"
          request['oauth_verifier'] = nil
        end
        super
      end
    end
  end
end
