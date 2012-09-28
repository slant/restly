module OauthResource::Configuration

  def self.config
    defaults = {
      session_key: :access_token,
      load_middleware: true,
      :authorize_url    => '/oauth/authorize',
      :token_url        => '/oauth/token',
      :token_method     => :post,
      :connection_opts  => {},
      :connection_build => block,
      :max_redirects    => 5,
      :raise_errors     => true
    }
    defaults.merge(@config || {})
  end

  def self.client_options
    @config.select do |k,v|
      [ :authorize_url,
        :token_url,
        :token_method,
        :connection_opts,
        :max_redirects,
        :raise_errors
      ].include?(k)
    end
  end

  def self.load_config(hash)
    @config = hash
  end

  def self.method_missing(m, *args, &block)
    config.with_indifferent_access[m]
  end

  def respond_to_missing?
    true
  end

  load_config YAML.load_file(File.join(Rails.root, 'config', 'oauth_resource.yml'))[Rails.env] if defined? Rails

end