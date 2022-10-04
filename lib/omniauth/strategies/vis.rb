# frozen_string_literal: true

require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Vis < OmniAuth::Strategies::OAuth2
      option :name, :vis

      option :client_options,
        site: Rails.application.config.vis['app_url'],
        authorize_path: '/oauth/authorize'

      def on_path?(path)
        current_path.squeeze('/').casecmp(path.squeeze('/')).zero?
      end

      def setup_phase
        # Authorize extra params
        authorized_params = [:locale, :confirm_identity, :allow_sign_up,
          :allowed_external_providers, :extra_agreement_title, :extra_agreement_text]
        authorized_params.each do |param|
          request.env['omniauth.strategy'].options[:authorize_params][param] = request.params[param.to_s]
        end
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
