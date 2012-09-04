module OauthResource::Base::Resource::ClassMethods

  def new(*args)
    super(*args)
  end

  # Authorize and New should be the same thing
  alias_method :authorize, :new

  # Delegate the new method to an authorized resource
  def new
    self.authorize.new
  end

  # Defines the resource client
  def client
    connection_opts ||= {}
    connection_opts[:headers] = { :'Accept' => "application/#{format}" }
    OAuth2::Client.new(client_id, client_secret, site: site, connection_opts: connection_opts)
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

  def format=(value)
    define_singleton_method :format do
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
    name.gsub(/.*::/,'').underscore
  end

  def format
    OauthResource::Configuration.default_format
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

  def path_with_format
    [path,format.to_s].compact.join('.')
  end

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
  ## Handle Un-Authorized Instances
  ############################################################

  def method_missing(m, *args, &block)
    if self.authorize.respond_to?(m)
      self.authorize.send(m, *args, &block)
    else
      super
    end
  end

end
