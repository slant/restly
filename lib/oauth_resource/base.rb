module OauthResource
  class Base
    # Autoload
    extend ActiveSupport::Autoload
    autoload :Collection
    autoload :Pagination
    autoload :Resource
    autoload :Instance
    autoload :Collection
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

    # Relationships
    include OauthResource::Relationships

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
                    :permitted_attributes,
                    :params

    # Setup global defaults
    self.client_id            =   OauthResource::Configuration.client_id
    self.client_secret        =   OauthResource::Configuration.client_secret
    self.site                 =   OauthResource::Configuration.site
    self.format               =   OauthResource::Configuration.default_format
    self.include_root_in_json =   OauthResource::Configuration.include_root_in_json || false
    self.params               =   {}

    class << self

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

      def resource_attrs_from_spec!
        resource_attr spec['attributes']
      end

      def resource
        self
      end

    end

    # Run Active Support Load Hooks
    ActiveSupport.run_load_hooks(:oauth_resource, self)

  end
end