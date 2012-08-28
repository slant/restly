module OauthResource::Base::Resource::ClassMethods

  def new(*args)
    super(*args)
  end

  # Authorize and New should be the same thing
  alias_method :authorize, :new

  # Defines the resource client
  def client
    OAuth2::Client.new(client_id, client_secret, site: site)
  end

  # Override Default Values
  def site=(value)
    define_singleton_method :site do
      value
    end
  end

  def path=(value)
    define_singleton_method :path do
      value
    end
  end

  def resource_name=(value)
    define_singleton_method :resource_name do
      value
    end
  end

  def client_id=(value)
    define_singleton_method :client_id do
      value
    end
  end

  def client_secret=(value)
    define_singleton_method :client_secret do
      value
    end
  end

  def cache(opts={})
    define_method :cache_opts do
      opts
    end
  end

  # Default Values

  def resource_name
    name.parameterize
  end

  def path
    resource_name.pluralize
  end

  def site
    OauthResource::Configuration.site
  end

  def client_id
    OauthResource::Configuration.client_id
  end

  def client_secret
    OauthResource::Configuration.client_secret
  end

  private

  ############################################################
  ## Defines ::Instance and ::Collection in subclasses
  ############################################################

  def inherited(subclass)
    subclass.send :class_eval, %{
      class Instance < OauthResource::Base::Instance ; end
      class Collection < OauthResource::Base::Collection ; end
    }
  end

  ############################################################
  ### Resource Relationships
  ############################################################

  def belongs_to_resource(resource, opts={})
    "#{name}::Instance".constantize.send :define_method, resource do
      model = resource.to_s.camelize.constantize
      model.authorize( self.resource.connection, path: opts[:path] ).find(send(:"#{resource}_id"))
    end
  end

  def has_one_resource(resource, opts={})
    "#{name}::Instance".send :define_method, resource do
      model = resource.to_s.camelize.constantize
      path = opts[:absolute_path] ? opts[:path] : [self.resource.path, id, (opts[:path] || resource.to_s) ].join('/')
      model.authorize( self.resource.connection, path: path ).all.first
    end
  end

  def has_many_resources(resources, opts={})
    "#{name}::Instance".send :define_method, resources do
      model = resources.to_s.singularize.camelize.constantize
      path = opts[:absolute_path] ? opts[:path] : [self.resource.path, id, (opts[:path] || resources.to_s) ].join('/')
      model.authorize( self.resource.connection, path: path ).all
    end
  end

  ############################################################
  ## Handle Un-Authorized Instances
  ############################################################

  def method_missing(m, *args, &block)
    if self.new.respond_to?(m)
      self.new.send(m, *args, &block)
    else
      super
    end
  end

end
