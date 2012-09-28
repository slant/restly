class OauthResource::Client < OAuth2::Client

  attr_accessor :id, :secret, :site
  attr_reader :format

  def initialize(*args, &block)
    opts = args.extract_options!
    self.id =     args[0] || OauthResource::Configuration.client_id
    self.secret = args[1] || OauthResource::Configuration.client_secret
    self.secret = client_secret
    self.site = opts.delete(:site) || OauthResource::Configuration.site
    self.options = OauthResource::Configuration.client_options.merge(opts)
    self.ssl = opts.delete(:ssl) || OauthResource::Configuration.ssl
    self.format = @format = opts.delete(:format) || OauthResource::Configuration.default_format
    self.options[:connection_build] = block
  end

  def ssl=(val)
    self.options[:connection_opts][:ssl] = val if val
  end

  def format=(val)
    self.options[:connection_opts][:headers] = { Accept: "application/#{format}" }
  end

  OauthResource::Configuration.client_options.keys.each do |m|
    define_method "#{m}=" do |val|
      self.options[m] = val
    end
  end

end