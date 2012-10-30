class Restly::Client < OAuth2::Client

  attr_accessor :id, :secret, :site
  attr_reader :format

  def initialize(*args, &block)
    opts = args.extract_options!
    self.id =     args[0] || Restly::Configuration.oauth_options[:client_id]
    self.secret = args[1] || Restly::Configuration.oauth_options[:client_secret]
    self.site = opts.delete(:site) || Restly::Configuration.site
    self.options = Restly::Configuration.client_options.merge(opts)
    self.ssl = opts.delete(:ssl) || Restly::Configuration.ssl
    self.format = @format = opts.delete(:format) || Restly::Configuration.default_format
    self.options[:connection_build] = block
  end

  def ssl=(val)
    self.options[:connection_opts][:ssl] = val if val
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