class OauthResource::Connection < Oauth2::Access Token

  attr_accessor :cache_options

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