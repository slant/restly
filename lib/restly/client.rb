class Restly::Client < OAuth2::Client

  attr_accessor :id, :secret, :site, :base_path
  attr_reader :format, :resource, :site

  def initialize(*args, &block)
    opts = args.extract_options!
    opts.merge!(raise_errors: false)

    # Set Resource
    self.resource  = opts.delete(:resource) if opts[:resource]
    self.id        = args[0] || Restly::Configuration.oauth_options[:client_id]
    self.secret    = args[1] || Restly::Configuration.oauth_options[:client_secret]

    # Set URL
    self.site      = opts.delete(:site) || Restly::Configuration.site

    self.options   = Restly::Configuration.client_options.merge(opts)
    self.ssl       = opts.delete(:ssl) || Restly::Configuration.ssl
    self.format    = @format = opts.delete(:format) || Restly::Configuration.default_format
    self.options[:connection_build] ||= block

  end

  def resource=(resource)
    raise InvalidObject, "Resource must be a descendant of Restly::Base" unless resource.ancestors.include?(Restly::Base)
    @resource = resource
  end

  def resource_name
    resource.name.parameterize
  end

  def ssl=(val)
    self.options[:connection_opts][:ssl] = val if val
  end

  def site=(val)
    url     =        URI.parse(val)
    scheme  =       "#{url.scheme}://"
    host    =       url.host
    port    =       url.port == 80 || url.port == 443 ? nil : ":#{url.port}"
    @site           = [scheme, host, port].compact.join
    @base_path      = url.path
  end

  def format=(val)
    self.options[:connection_opts][:headers] = {
        "Accept" => "application/#{format}",
        "Content-Type" => "application/#{format}"
    }
  end

  Restly::Configuration.client_options.keys.each do |m|
    define_method "#{m}=" do |val|
      self.options[m] = val
    end
  end

end