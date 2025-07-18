# frozen_string_literal: true

require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Vis < OmniAuth::Strategies::OAuth2
      option :name, :vis

      option :client_options,
        authorize_path: '/oauth/authorize'

      option :scope, 'default'

      option :server_url, "https://identity.dhamma.org"
      option :jwt_shared_secret, nil

      def setup_phase
        # configure Oauth2 client_options.site from a custom server_url option
        options.client_options.site = options.server_url

        # Authorize all params to be passed to VIS
        options.authorize_params = request.params.to_h
      end

      uid do
        raw_info['id']
      end

      info do
        raw_info
      end

      # Fix strange bugs with urls containing double / like dhamma.org//oauth/callback
      def on_path?(path)
        current_path.squeeze('/').casecmp(path.squeeze('/')).zero?
      end

      # to fix always getting invalid_grant error
      # see https://github.com/omniauth/omniauth-oauth2/issues/81#issuecomment-231442739
      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        return @raw_info if @raw_info.present?

        @raw_info = if options.jwt_shared_secret.present?
                      # get info from the JWT token, so we save an API call
                      JWT.decode(
                        access_token.token,
                        options.jwt_shared_secret,
                        true,
                        { algorithm: "hs512" }
                      ).first["user"]
                    else
                      # get info from API
                      access_token.get("/api/v1/me.json").parsed
                    end
      end
    end
  end
end
