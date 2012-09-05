module OauthResource::Errors
  class NotAnOauthResource < StandardError
    def message
      'Object is not an oauth resource!'
    end
  end
end