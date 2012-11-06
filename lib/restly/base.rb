module Restly
  class Base
    # Autoload
    extend ActiveSupport::Autoload
    autoload :Resource
    autoload :Instance
    autoload :GenericMethods
    autoload :Includes
    autoload :MassAssignmentSecurity
    autoload :Fields
    autoload :EmbeddedAssociations

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
    define_model_callbacks :create, :save, :destroy, :update, :initialize

    # Concerned Inheritance
    include Restly::ConcernedInheritance

    # Actions & Callbacks
    extend  Resource
    include Includes
    include Instance
    include Fields
    include MassAssignmentSecurity

    # Relationships
    include Restly::Associations
    include Restly::EmbeddedAssociations

    # Set up the Attributes
    thread_local_accessor :current_token
    class_attribute :path, instance_writer: false, instance_reader: false
    class_attribute :resource_name,
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
    self.client_token         =   Restly::Configuration.use_oauth ? (client.client_credentials.get_token rescue nil) : nil

    # Set Defaults on Inheritance
    inherited do
      field :id
      self.resource_name      = name.gsub(/.*::/,'').underscore if name.present?
      self.path               = resource_name.pluralize
      self.params             = params.dup
    end

    # Run Active Support Load Hooks
    ActiveSupport.run_load_hooks(:restly, self)

    # Alias the class for delegation
    def client
      self.class.client
    end

    def resource
      self.class
    end

  end
end