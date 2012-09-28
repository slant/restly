module OauthResource
  class Railtie < ::Rails::Railtie

    initializer "my_engine.add_middleware" do |app|
      app.middleware.use "OauthResource::Middleware" if OauthResource::Configuration.load_middleware
    end

  end
end