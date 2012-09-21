class OauthResource::Proxies::Params < OauthResource::BaseProxy

  def initialize(requester, params)
    super(requester)
    self.params = params
  end

end