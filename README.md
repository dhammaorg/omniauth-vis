# omniauth-vis

This small gem will help Rails apps to connect to Vipassana Identity Server (VIS) using Auth2

It provides:
- a strategy file to be used with `omniauth` gem
- a service to request VIS APIs endpoints

## Register your app

Contact VIS administrators (sebastian.castro@dhamma.org, ryan.johnson@dhamma.org, nilendu.jani@dhamma.org) and provide following informations about your app:

- Name
- Home page url
- Logo url
- Authorized callback urls (example: https://myapp.org/users/auth/vis/callback)

## Install the gem

```
gem add omniauth-vis
```

## Configure

```
# config/initializers/vis.rb

Rails.application.config.vis = {
  app_id: "APP_ID_PROVIDED",
  app_secret: "APP_SECRET_PROVIDED",
  app_url: "https://identity.server.dhamma.org/"
}
```

## Use omniauth strategy

You first need to install `omniauth-oauth2` gem, then add a new provider :

```
# config/initializers/omniauth.rb

require "omniauth/strategies/vis"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :vis, Rails.application.config.vis["app_id"], Rails.application.config.vis["app_secret"],
    {
      scope: "default"
    }
end
```

## Use VIS API

`Vis::Api` will implement [Oauth2 Client Credentials Flow](https://auth0.com/docs/get-started/authentication-and-authorization-flow/client-credentials-flow) behind the scene

```
require "vis/api"
@vis_api = Vis::Api.new
@vis_service.get("api_path")
@vis_service.post("api_path", data)
```

Documentation about available api can be found at [https://identity.server.dhamma.org/doc](https://identity.server.dhamma.org/doc)

Example

```
Vis::Api.new.post("/api/v1/users", {
  email: "email@test.com",
  username: "test",
  encrypted_password: "xxxxxxxxxx"
})
```

## Developers, how to publish new version of the gem

```
gem build omniauth-vis
gem push omniauth-vis-X.X.X.gem
```