class OauthResource::Proxies::Association < OauthResource::BaseProxy

  attr_reader :parent, :joiner

  def initialize(requester, parent, joiner=nil)
    super(requester)
    @parent = parent
    @joiner = joiner
  end

  def << (obj)

  end


end