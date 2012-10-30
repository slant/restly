module Restly
  class Railtie < ::Rails::Railtie

    generators do
      require "generators/restly_model_generator"
      require "generators/restly_config_generator"
    end

    initializer "my_engine.add_middleware" do |app|
      app.middleware.use "Restly::Middleware" if Restly::Configuration.load_middleware
    end

  end
end