module Restly
  class Railtie < ::Rails::Railtie

    initializer "my_engine.add_middleware" do |app|
      app.middleware.use "Restly::Middleware" if Restly::Configuration.load_middleware
    end

  end
end