module Restly::ControllerMethods

  def auth_token
    @oauth_token ||= session[Restly::Configuration.session_key].try(:dup) || {}
  end

  def auth_token=(token_object)
    session[Restly::Configuration.session_key] = Restly::Connection.tokenize(Restly::Base.client, token_object).to_hash
  end

end