class Restly::Middleware

  attr_reader :app, :env

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env

    Restly::Base.current_token = nil

    token = Restly::Connection.tokenize(Restly::Base.client, self).to_hash

    if token[:access_token].present? && !@env['PATH_INFO'].match(/^\/assets\//)
      Restly::Base.current_token = token
    end

    self.app.call(env)

  ensure

    Restly::Base.current_token = nil

  end

end