# omniauth-vis

This small gem will help Rails apps to connect to Vipassana Identity Server (VIS) using Auth2

It provides:
- a strategy file to be used with `omniauth` gem
- a service to request VIS APIs endpoints

## Register your app

Contact VIS administrators (sebastian.castro@dhamma.org, ryan.johnson@dhamma.org, nilendu.jani@dhamma.org) and provide following informations about your app:

- Name
- Home page url
- Authorized callback urls (example: https://myapp.org/users/auth/vis/callback)

## Install the gem

```
gem add omniauth
gem add omniauth-vis
```

## Use omniauth strategy

```
# config/initializers/omniauth.rb

require "omniauth/strategies/vis"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :vis, Rails.application.config.vis["app_id"], Rails.application.config.vis["app_secret"]
end
```

### Customize VIS server

In case you need to work with a custom server, for exmaple a staging server, you can use server_url option
```
provider :vis, Rails.application.config.vis["app_id"], Rails.application.config.vis["app_secret"], {
  server_url: "https://test.identity.dhamma.org"
}
```

## Use VIS API

`Vis::Api` will implement [Oauth2 Client Credentials Flow](https://auth0.com/docs/get-started/authentication-and-authorization-flow/client-credentials-flow) behind the scene

```
require "vis/api"
@vis_api = Vis::Api.new(client_id: "xx", client_secret: "xx", server_url: "https://identity.dhamma.org")
@vis_api.get("api_path")
@vis_api.post("api_path", data)
```

The API documentation can be found at [https://identity.dhamma.org/doc](https://identity.dhamma.org/doc).
It is automatically generated from the VIS API Users Controller code deployed on production, through the `apipie-rails` gem.

Example

```
@vis_api.post("/api/v1/users", {
  email: "email@test.com",
  username: "test",
  encrypted_password: "xxxxxxxxxx"
})
```
## Developers, how to publish new version of the gem

* update the `CHANGELOG.md` file, see https://keepachangelog.com
* increase `gem.version` in `omniauth-vis.gemspec`
* `gem build omniauth-vis`
* `gem push omniauth-vis-X.X.X.gem`
