# Vipassna Identity Server Service - for server to server Oauth 2 client_credentials grant flow
# gets tokens so we can use the VIS API
module Vis
  class OauthError < StandardError;  end

  class Api
    def initialize(server_url: "https://identity.dhamma.org", client_id:, client_secret:)
      @client_id = client_id
      @client_secret = client_secret
      @vis_app_url = server_url
      @use_ssl = !Rails.env.development?
    end

    def token
      return @token if @token && @expiry && Time.now.utc < @expiry

      response = token_post
      result = JSON.parse(response.body)
      check_error!(response.code, result)

      @expiry = (Time.now.utc + result["expires_in"] - 1)
      @token = result["access_token"]
    end

    # we can catch VisOauthErrors in our code if we decide to use VIS API as part of any request flow or backend task
    private def check_error!(response_code, response_body_hash)
      return unless response_body_hash["error"].present? || !response_code.in?(["200", "202"]) # 201 ?

      raise Vis::OauthError,
        "#{response_code} Error requesting token from Vipassana Identity Server. "\
        "#{response_body_hash['error']} #{response_body_hash['error_description']}"
    end

    private def token_post
      http_client, uri = http_client_and_uri "/oauth/token"
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({ "client_id" => @client_id, "client_secret" => @client_secret,
        "grant_type" => "client_credentials" })
      http_client.request(request)
    end

    def get(path)
      http_client, uri = http_client_and_uri path
      response = http_client.get(uri, headers)
      return_response(response)
    end

    def delete(path)
      http_client, uri = http_client_and_uri path
      response = http_client.delete(uri, headers)
      return_response(response)
    end

    def post(path, post_params_hash)
      http_client, uri = http_client_and_uri path
      response = http_client.post(uri, post_params_hash.to_json, headers)
      return_response(response)
    end

    private def return_response(response)
      if response.body.blank?
        {} # TODO: consider also returning or checking response.status, should be 202 for forward message
      else
        JSON.parse(response.body) # this is sometimes a blank string which raises error if JSON.parse is done on it
      end
    end

    private def http_client_and_uri(path)
      path = "/#{path}" unless path&.starts_with?("/")
      uri = URI.parse("#{@vis_app_url}#{path}")
      client = Net::HTTP.new(uri.hostname, uri.port)
      client.use_ssl = @use_ssl
      [client, uri]
    end

    private def headers
      auth_headers.merge({ "Content-type" => "application/json" })
    end

    private def auth_headers
      { "Authorization" => "Bearer #{token}" }
    end

  end
end
