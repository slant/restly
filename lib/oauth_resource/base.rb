module OauthResource
  class Base
    # Autoload
    extend ActiveSupport::Autoload
    autoload :Pagination
    autoload :Resource
    autoload :Instance
    autoload :Collection
    autoload :GenericMethods

    # Thread Local Accessor
    extend OauthResource::ThreadLocal

    # Active Model
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks
    extend  ActiveModel::Translation
    include ActiveModel::Conversion
    include ActiveModel::Dirty
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Observing
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    # Actions
    extend  Resource
    include Instance

    # Relationships
    include OauthResource::Relationships

    # Set up the Attributes
    thread_local_accessor :current_connection
    class_attribute :resource_name,
                    :path,
                    :include_root_in_json,
                    :connection,
                    :permitted_attributes,
                    :params,
                    :cache,
                    :cache_options,
                    :client_token


    self.include_root_in_json =   OauthResource::Configuration.include_root_in_json
    self.cache                =   OauthResource::Configuration.cache
    self.cache_options        =   OauthResource::Configuration.cache
    self.params               =   {}
    self.current_connection   =   {}
    self.client_token         =   client.client_credentials.get_token rescue nil

    class << self

      # Delegate stuff to client
      delegate :site, :site=, :format, :format=, to: :client

      def client
        @client ||= OauthResource::Client.new
      end

      def connection
        OauthResource::Connection.tokenize(client, current_connection.merge({cache_options: cache_options}))
      end

      private

      def inherited(subclass)
        subclass.resource_name  = subclass.name.gsub(/.*::/,'').underscore
        subclass.path           = subclass.resource_name.pluralize
      end

      def resource_attr(*attrs)
        self.permitted_attributes ||= []
        attrs.flatten.compact.map(&:to_sym).each do |attr|
          unless instance_method_already_implemented? attr
            define_attribute_method attr
            self.permitted_attributes << attr
            self.permitted_attributes.uniq!
          end
        end
      end

      def resource
        self
      end

    end

    # Run Active Support Load Hooks
    ActiveSupport.run_load_hooks(:oauth_resource, self)

  end
end