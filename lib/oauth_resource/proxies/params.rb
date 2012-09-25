class OauthResource::Proxies::Params < OauthResource::BaseProxy

  def initialize(requester, params)
    super(requester)
    self.params.merge!(params)
  end

end