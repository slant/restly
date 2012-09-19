module OAuth2
  class AccessToken
    extend ActiveSupport::Concern

    attr_accessor :cache_opts
    attr_accessor :error

    def to_hash
      {
        access_token: token,
        refresh_token: refresh_token,
        expires_at: expires_at
      }
    end

    alias_method :forced_request, :request

    def request(verb, path, opts={}, &block)
      if cache_opts.present? && !opts[:force]
        cached_request(verb, path, opts, &block)
      else
        forced_request(verb, path, opts, &block)
      end
    end

    def cached_request(verb, path, opts={}, &block)
      key = [path.parameterize, Digest::MD5.hexdigest([Marshal.dump({verb: verb, token: token, opts: opts, block: block })].pack('m'))].compact.join('_')

      # Force a cache miss for all methods except get
      cache_opts[:force] = true unless [:get].include?(verb)

      # Set the response
      response = Rails.cache.fetch key, cache_opts do
        Rails.cache.delete_matched("#{path.parameterize}*") if ![:get].include?(verb)
        opts.merge!({force: true})
        request(verb, path, opts, &block)
      end

      # Clear the cache if there is an error
      Rails.cache.delete(key) if response.error

      # Return the response
      response

    end

  end
end