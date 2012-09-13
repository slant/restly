module OauthResource
  class Base
    # Autoload
    extend ActiveSupport::Autoload
    autoload :Collection
    autoload :Pagination
    autoload :ResourceActions
    autoload :InstanceActions
    autoload :CollectionActions
    autoload :GenericMethods

    # Active Model
    extend  ActiveModel::Naming
    extend ActiveModel::Callbacks
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    include ActiveModel::Dirty

    # Actions
    extend  OauthResource::Base::ResourceActions
    include OauthResource::Base::InstanceActions
    include OauthResource::Base::Pagination

    # Delegate the client to the class
    delegate :client, to: :klass

    # Set up the Attributes
    class_attribute :client_id,
                    :client_secret,
                    :site,
                    :resource_name,
                    :path,
                    :format,
                    :include_root_in_json,
                    :connection,
                    :permitted_attributes

    # Setup global defaults
    self.client_id            =   OauthResource::Configuration.client_id
    self.client_secret        =   OauthResource::Configuration.client_secret
    self.site                 =   OauthResource::Configuration.site
    self.format               =   OauthResource::Configuration.default_format
    self.include_root_in_json =   OauthResource::Configuration.include_root_in_json || false

    private

    def instance
      self
    end

    def klass
      self.class
    end

    class << self

      def load(attributes = nil, options = {})
        self.new(attributes, options.merge({loaded: true}))
      end

      def inherited(subclass)
        subclass.resource_name  = subclass.name.gsub(/.*::/,'').underscore
        subclass.path           = subclass.resource_name.pluralize
        subclass.connection     = OAuth2::AccessToken.new(client, nil)
        subclass.resource_attr :id # subclass.spec[:attributes]
      end

      def client
        OAuth2::Client.new(
          client_id,
          client_secret,
          site: site,
          raise_errors: false,
          connection_opts: {
            headers: {
              Accept: "application/#{format}"
            }
          }
        )
      end

      def resource_attr(*attrs)
        attrs.each do |attr|
          permitted_attributes ||= []
          permitted_attributes += attrs
          define_attribute_methods attrs
        end
      end

      private

      def resource
        self
      end

    end

    # Run Active Support Load Hooks
    ActiveSupport.run_load_hooks(:oauth_resource, self)

  end
end