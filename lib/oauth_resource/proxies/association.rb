class OauthResource::Proxies::Association < OauthResource::BaseProxy

  attr_reader :parent, :joiner

  def initialize(requester, parent, joiner=nil)
    super(requester)
    @parent = parent
    @joiner = joiner
  end

  def <<(instance)
    collection = super
    joiner.create("#{parent.resource_name}_id" => parent.id, "#{instance.resource_name}_id" => instance.id) if joiner
    collection
  end

end