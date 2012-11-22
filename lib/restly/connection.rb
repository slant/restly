class Restly::Connection < OAuth2::AccessToken

  attr_accessor :cache, :cache_options

  delegate :resource, :resource_name, :base_path, to: :client

  # TODO: Refactor with subclasses that have their own tokenize methods.
  def self.tokenize(client, object)

    if object.is_a?(Hash)
      from_hash(client, object)

    elsif object.is_a?(Rack::Request)
      from_rack_request(client, object)

    elsif object.is_a?(OAuth2::AccessToken)
      from_token_object(client, object)

    elsif object.is_a?(Restly::Middleware)

      /(?<token>\w+)$/i =~ object.env['HTTP_AUTHORIZATION']
      return from_rack_request(client, object) if token
      token_hash = object.env['rack.session'][Restly::Configuration.session_key] || {}
      from_hash(client, token_hash)

    else
      new(client, nil)

    end

  end

  def initialize(client, token, opts={})
    self.cache_options = opts[:cache_options] || {}
    self.cache = opts[:cache]
    super
  end

  def self.from_hash(client, token_hash)
    super(client, token_hash.dup)
  end

  def self.from_rack_request(client, rack_request)
    /(?<token>\w+)$/i =~ rack_request.env['HTTP_AUTHORIZATION']
    from_hash(client, { access_token: token })
  end

  def self.from_token_object(client, token_object)
    from_hash(client, {
      access_token:   token_object.token,
      refresh_token:  token_object.refresh_token,
      expires_at:     token_object.expires_at
    })
  end

  def to_hash
    {
      access_token: token,
      refresh_token: refresh_token,
      expires_at: expires_at
    }
  end

  alias_method :forced_request, :request

  def request(verb, path, opts={}, &block)
    path = [base_path.gsub(/\/?$/, ''), path.gsub(/^\/?/, '')].join('/')

    if cache && !opts[:force]
      request_log("Restly::CacheRequest", path, verb) do
        cached_request(verb, path, opts, &block)
      end
    else
      request_log("Restly::Request", path, verb) do
        forced_request(verb, path, opts, &block)
      end
    end
  end

  def id_from_path(path)
    capture = path.match /(?<id>[0-9])\.\w*$/
    capture[:id] if capture
  end

  def cached_request(verb, path, opts={}, &block)
    id = id_from_path(path)

    cache_options = self.cache_options.dup
    options_hash = { path: path, verb: verb, token: token, opts: opts, cache_opts: cache_options, block: block }
    options_packed = [Marshal.dump(options_hash)].pack('m')
    options_hex = Digest::MD5.hexdigest(options_packed)

    # Keys
    collection_expire_key = [resource_name, "*"].compact.join('_')
    instance_expire_key = [id, resource_name, "*"].compact.join('_')
    cache_key = [id, resource_name, options_hex].compact.join('_')


    # Force a cache miss for all methods except get
    cache_options[:force] = true unless [:get, :options].include?(verb)

    # Set the response
    unless verb.to_s.upcase =~ /GET|OPTIONS/

      # Expire Collections
      cache_log("Restly::CacheExpire", instance_expire_key, :yellow) do
        Rails.cache.delete_matched(collection_expire_key)
      end

      # Expire Instances
      cache_log("Restly::CacheExpire", instance_expire_key, :yellow) do
        Rails.cache.delete_matched(instance_expire_key)
      end
    end

    response =  Rails.cache.fetch cache_key, cache_options.symbolize_keys do
      cache_log("Restly::CacheMiss", cache_key, :red) do
                    forced_request(verb, path, opts, &block)
                  end
                end

    cache_log("Restly::CacheExpire", cache_key, :yellow) { Rails.cache.delete(cache_key) } if response.error

    if response.status >= 500
      site = URI.parse(client.site)
      formatted_path = ["#{site.scheme}://#{site.host}", "#{site.port}", path].join
      raise Restly::Error::ConnectionError, "#{response.status}: #{status_string(response.status)}\nurl: #{formatted_path}"
    end

    # Return the response
    response

  end

  def request_log(name, path, verb, color=:light_green, &block)
    site = URI.parse(client.site)
    formatted_path = ["#{site.scheme}://#{site.host}", ":#{site.port}", path].join
    ActiveSupport::Notifications.instrument("request.restly", url: formatted_path, method: verb, name: name, color: color, &block)
  end

  def cache_log(name, key, color=:light_green, &block)
    ActiveSupport::Notifications.instrument("cache.restly", key: key, name: name, color: color, &block)
  end

  def status_string(int)
    Rack::Utils::HTTP_STATUS_CODES[int.to_i]
  end

end