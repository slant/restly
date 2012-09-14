module OauthResource
  class Base
    # Autoload
    extend ActiveSupport::Autoload
    autoload :Collection
    autoload :Pagination
    autoload :Resource
    autoload :Instance
    autoload :CollectionActions
    autoload :GenericMethods

    # Active Model
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks
    extend  ActiveModel::Translation
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    include ActiveModel::Dirty
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Observing
    include ActiveModel::Validations

    # Actions
    extend  OauthResource::Base::Resource
    include OauthResource::Base::Instance
    include OauthResource::Base::Pagination

    # Relationships
    include OauthResource::Relationships

    # Delegate the client to the class
    delegate :client, :permitted_attributes, to: :klass

    # Set up the Attributes
    class_attribute :client_id,
                    :client_secret,
                    :site,
                    :resource_name,
                    :path,
                    :format,
                    :include_root_in_json,
                    :connection,
                    :_permitted_attributes

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
        subclass.resource_attr :id
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

      def connection
        OAuth2::AccessToken.new(client, nil)
      end

      def resource_attr(*attrs)
        self._permitted_attributes ||= []
        attrs.flatten.compact.map(&:to_sym).each do |attr|
          unless instance_method_already_implemented? attr
            define_attribute_method attr
            self._permitted_attributes << attr
            self._permitted_attributes.uniq!
          end
        end
      end

      def permitted_attributes
        resource_attr spec['attributes']
        _permitted_attributes
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