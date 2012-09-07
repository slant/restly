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

  def cache(opts={})
    define_method :cache_opts do
      opts
    end
  end

  private

  def path_with_format
    [path,format.to_s].compact.join('.')
  end

  def rattr_accessor(*attrs)
    attrs.each do |attr|

      # Setter
      define_singleton_method :"#{attr}=" do |value|

        # Getter
        define_singleton_method attr do
          value
        end

      end

      # Nil
      define_singleton_method attr do
        nil
      end

    end
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

end
