module OauthResource::Configuration

  def self.config
    defaults = {
      session_key: :access_token,
      load_middleware: true
    }
    defaults.merge(@config || {})
  end

  def self.load_config(hash)
    @config = hash
  end

  def self.method_missing(m, *args, &block)
    config.with_indifferent_access[m]
  end

  load_config YAML.load_file(File.join(Rails.root, 'config', 'oauth_resource.yml'))[Rails.env] if defined? Rails

end