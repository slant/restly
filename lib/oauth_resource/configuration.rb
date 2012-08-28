module OauthResource::Configuration

  def self.config
    YAML.load_file(File.join(Rails.root, 'config', 'endpoints.yml'))[Rails.env]
  end

  def self.method_missing(m, *args, &block)
    config.with_indifferent_access[m]
  end

end