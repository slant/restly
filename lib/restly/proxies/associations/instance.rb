class Restly::Proxies::Associations::Instance < Restly::Proxies::Base

  attr_reader :parent, :joiner

  def initialize(instance, parent, joiner=nil)
    super(instance)
    @parent = parent
    @joiner = joiner
  end

end