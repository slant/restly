class Restly::Middleware

  attr_reader :app, :env

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    Restly::Base.current_token = Restly::Connection.tokenize(Restly::Base.client, self).to_hash
    self.app.call(self.env)
  end

end