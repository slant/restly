module OauthResource
  class Railtie < ::Rails::Railtie

    config.after_initialize do
      Rails.configuration.middleware.use("OauthResource::Middleware") if OauthResource::Configuration.load_middleware
    end

  end
end