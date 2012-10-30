module Restly
  module Generators
    class ConfigGenerator < Rails::Generators::Base

      source_root File.expand_path("../templates", __FILE__)

      def create_config_file
        template "config.yml.erb", "config/restly.yml"
      end

    end
  end
end