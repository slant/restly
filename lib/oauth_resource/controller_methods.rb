module OauthResource::ControllerMethods
  extend ActiveSupport::Concern

  included do

    private

    def auth_token
      @oauth_token ||= OAuth2::AccessToken.from_hash(OauthResource::Base::client, ( session[:oauth_token].try(:dup) || {} ))
    end

  end

end