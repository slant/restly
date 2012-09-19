class OauthResource::Proxies::Params < OauthResource::BaseProxy

  attr_accessor :params

  def initialize(requester, params)
    super(requester)
    self.params = params
  end

end