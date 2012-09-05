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
      key = [path, [Marshal.dump({verb: verb, token: token, opts: opts, block: block })].pack('m')].compact.join('_')

      # Set the response
      cache_opts[:force] = true unless [:get, :options].include?(verb)
      response = Rails.cache.fetch key, cache_opts do
        Rails.cache.delete_matched("#{path}*") if ![:get, :options].include?(verb)
        opts.merge!({force: true})
        request(verb, path, opts, &block)
      end

      Rails.cache.delete(key) if error

      response

    end

    class << self

      def from_headers(client, headers)
        token = headers['authorization'].try(:gsub, /Bearer (.*)/, "\\1")
        from_hash(client, { access_token: token })
      end

    end

  end
end