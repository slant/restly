module Restly::Configuration

  def self.config
    defaults = {
      session_key: :access_token,
      load_middleware: true,
      use_oauth: false,
      cache: false,
      default_format: :json,
      oauth_options: {
        :authorize_url    => '/oauth/authorize',
        :token_url        => '/oauth/token',
        :token_method     => :post,
      },
      client_options: {
        :connection_opts  => {},
        :max_redirects    => 5,
        :raise_errors     => true
      }
    }
    config = defaults.deep_merge(@config || {})
    config.assert_valid_keys(:session_key, :load_middleware, :oauth_options, :use_oauth, :cache, :cache_options, :client_options, :site, :default_format)
    config
  end

  def self.client_options
    config[:client_options].merge(config[:oauth_options])
  end

  def self.load_config(hash)
    @config = hash.symbolize_keys
  end

  def self.method_missing(m, *args, &block)
    config.with_indifferent_access[m]
  end

  def respond_to_missing?
    true
  end

  config_file = File.join(Rails.root, 'config', 'restly.yml')
  load_config YAML.load_file(config_file)[Rails.env] if defined?(Rails) && File.exists?(config_file)

end