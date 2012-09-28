class OauthResource::Middleware

  attr_reader :app, :env

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    OauthResource::Base.current_connection = OauthResource::Connection.tokenize(OauthResource::Base.client, self).to_hash
    app.call(env)
  end

end