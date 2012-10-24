module Restly
  class Base
    # Autoload
    extend ActiveSupport::Autoload
    #autoload :Pagination # Todo!
    autoload :Resource
    autoload :Instance
    autoload :Collection
    autoload :GenericMethods
    autoload :Includes
    autoload :WriteCallbacks
    autoload :MassAssignmentSecurity
    autoload :Fields

    # Thread Local Accessor
    extend Restly::ThreadLocal

    # Active Model
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks
    extend  ActiveModel::Translation
    extend  ActiveModel::Callbacks
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Conversion
    include ActiveModel::Dirty
    include ActiveModel::Observing
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    # Set Up Callbacks
    define_model_callbacks :create, :save, :delete, :update, :initialize

    # Actions & Callbacks
    extend  Resource
    include Includes
    include Instance
    include Fields
    include MassAssignmentSecurity
    include WriteCallbacks

    # Relationships
    include Restly::Associations

    # Set up the Attributes
    thread_local_accessor :current_token
    class_attribute :resource_name,
                    :path,
                    :include_root_in_json,
                    :params,
                    :cache,
                    :cache_options,
                    :client_token

    self.include_root_in_json =   Restly::Configuration.include_root_in_json
    self.cache                =   Restly::Configuration.cache
    self.cache_options        =   Restly::Configuration.cache_options
    self.params               =   {}
    self.current_token        =   {}
    self.client_token         =   client.client_credentials.get_token rescue nil

    # Set Defaults on Inheritance
    inherited do
      field :id
      self.resource_name          = name.gsub(/.*::/,'').underscore
      self.path                   = resource_name.pluralize
      self.params                 = params.dup
    end

    # Run Active Support Load Hooks
    ActiveSupport.run_load_hooks(:restly, self)

    delegate :client, to: :klass

    # Alias the class for delegation
    def klass
      self.class
    end

  end
end