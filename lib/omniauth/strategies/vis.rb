# frozen_string_literal: true

require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Vis < OmniAuth::Strategies::OAuth2
      option :name, :vis

      option :client_options,
        site: Rails.application.config.vis['server_url'],
        authorize_path: '/oauth/authorize'

      option :scope, 'default'

      def on_path?(path)
        current_path.squeeze('/').casecmp(path.squeeze('/')).zero?
      end

      def setup_phase
        # Authorize all params to be passed to VIS
        request.env['omniauth.strategy'].options[:authorize_params] = request.params.to_h
      end

      uid do
        raw_info['id']
      end

      info do
        raw_info
      end

      # to fix always getting invalid_grant error
      # see https://github.com/omniauth/omniauth-oauth2/issues/81#issuecomment-231442739
      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/me.json').parsed
      end
    end
  end
end
