module OauthResource::ControllerMethods
  extend ActiveSupport::Concern

  included do

    private

    def auth_token
      @oauth_token ||= session[:oauth_token].try(:dup) || {}
    end

  end

end