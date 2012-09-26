class OauthResource::Connection < OAuth2::AccessToken

  attr_accessor :cache_options

  def self.tokenize(client, object)
    if object.is_a?(Hash) && object.has_key?(:access_token)
      OauthResource::Connection.from_hash(client, object)

    elsif object.is_a?(Rack::Request)
      OauthResource::Connection.from_rack_request(client, object)

    elsif object.is_a?(OAuth2::AccessToken)
      OauthResource::Connection.from_token_object(client, object)

    else
      raise OauthResource::Error::InvalidToken, 'Invalid token format!'
    end
  end

  def self.from_rack_request(client, rack_request)
    /(?<token>\w+)$/i =~ rack_request.headers['HTTP_AUTHORIZATION']
    OauthResource::Connection.from_hash(client, { access_token: token })
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
    if cache_options.present? && !opts[:force]
      cached_request(verb, path, opts, &block)
    else
      forced_request(verb, path, opts, &block)
    end
  end

  private

  def cached_request(verb, path, opts={}, &block)
    options_hash = { verb: verb, token: token, opts: opts, block: block }
    options_packed = [Marshal.dump(options_hash)].pack('m')
    options_hex = Digest::MD5.hexdigest(options_packed)
    cache_key = [path.parameterize, options_hex].join('_')

    # Force a cache miss for all methods except get
    cache_options[:force] = true unless [:get].include?(verb)

    # Set the response
    response = Rails.cache.fetch cache_key, cache_options do
      Rails.cache.delete_matched("#{path.parameterize}*") if ![:get].include?(verb)
      opts.merge!({force: true})
      request(verb, path, opts, &block)
    end

    # Clear the cache if there is an error
    Rails.cache.delete(cache_key) if response.error

    # Return the response
    response

  end
end