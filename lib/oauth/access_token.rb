module OAuth2
  class AccessToken

    attr_accessor :cache_opts
    attr_accessor :error

    def to_hash
      {
        access_token: token,
        refresh_token: refresh_token,
        expires_at: expires_at
      }
    end

    alias_method :old_get, :get

    def get(path, opts={}, &block)
      key = [[token, path, opts, block.to_s].join('')].pack('m')
      self.error = nil

      if token.present? && cache_opts.present?
        val = Rails.cache.fetch key, cache_opts do
          old_get(path, opts, &block)
        end
        Rails.cache.delete(key) if error
        val
      else
        old_get(path, opts, &block)
      end

    end

    alias_method :old_request, :request

    def request(verb, path, opts={}, &block)
      begin
        old_request(verb, path, opts, &block)
      rescue OAuth2::Error => error
        self.error = error.response
      end
    end

  end
end