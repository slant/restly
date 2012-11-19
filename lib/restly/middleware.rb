class Restly::Middleware

  attr_reader :app, :env

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    token = Restly::Connection.tokenize(Restly::Base.client, self).to_hash
    if token[:access_token].present? && !@env['PATH_INFO'].match(/^\/assets\//)
      thread = Thread.new do
        Restly::Base.current_token = token
        self.app.call(env)
      end
      thread.value
    else
      self.app.call(env)
    end
  end

end