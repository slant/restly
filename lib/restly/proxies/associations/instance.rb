class Restly::Proxies::Associations::Instance < Restly::Proxies::Base

  attr_reader :parent, :joiner

  def initialize(receiver, parent, joiner=nil)
    super(receiver)
    @parent = parent
    @joiner = joiner
  end

end