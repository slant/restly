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
    connection_opts[:headers] = { :'Accept' => "application/#{api_format}" }
    OAuth2::Client.new(client_id, client_secret, site: site, connection_opts: connection_opts, raise_errors: false)
  end

  def cache(opts={})
    define_method :cache_opts do
      opts
    end
  end

  private

  def path_with_format
    [path,api_format.to_s].compact.join('.')
  end

  ############################################################
  ## Defines ::Instance and ::Collection in subclasses
  ############################################################

  def inherited(subclass)

    # Set Default Cache
    cache (OauthResource::Configuration.cache_opts || {}) if OauthResource::Configuration.cache

    # Set Default Configuration
    subclass.resource_name = subclass.name.gsub(/.*::/,'').underscore
    subclass.path = subclass.resource_name.pluralize

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

  def respond_to?(symbol, include_private=false)
    begin
      send(symbol)
    rescue NameError
      false
    rescue NoMethodError
      false
    ensure
      true
    end
  end

end
