class Restly::Connection < OAuth2::AccessToken

  attr_accessor :cache, :cache_options

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
    if cache && !opts[:force]
      cached_request(verb, path, opts, &block)
    else
      forced_request(verb, path, opts, &block)
    end
  end

  private

  def cached_request(verb, path, opts={}, &block)
    cache_options = self.cache_options.dup

    options_hash = { verb: verb, token: token, opts: opts, cache_opts: cache_options, block: block }
    options_packed = [Marshal.dump(options_hash)].pack('m')
    options_hex = Digest::MD5.hexdigest(options_packed)
    cache_key = [path.parameterize, options_hex].join('_')

    # Force a cache miss for all methods except get
    cache_options[:force] = true unless [:get, :options].include?(verb)

    # Set the response
    response = Rails.cache.fetch cache_key, cache_options.symbolize_keys do

      Rails.cache.delete_matched("#{path.parameterize}*") if ![:get, :options].include?(verb)
      opts.merge!({force: true})
      request(verb, path, opts, &block)

    end

    # Clear the cache if there is an error
    Rails.cache.delete(cache_key) and puts "deleted cache for: #{verb} #{path}" if response.error

    # Return the response
    response

  end
end