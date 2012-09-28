class OauthResource::Middleware

  attr_reader :app, :env

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    Thread.current[:oauth_resource_token_hash] = OauthResource::Connection.tokenize(OauthResource::Base.client, self).to_hash
    app.call(env)
  end

end