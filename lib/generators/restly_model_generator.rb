module Restly
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase

      source_root File.expand_path("../templates", __FILE__)

      def initialize(args, *options) #:nodoc:
        args[0] = args[0].gsub(/\./,'_')
        super
      end

      def create_model_file
        template "model.rb.erb", "app/models/#{file_name}.rb"
      end

    end
  end
end