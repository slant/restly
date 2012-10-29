class Restly::Proxies::WithParams < Restly::Proxies::Base

  def initialize(receiver, params)
    super(receiver)
    self.params = self.params.merge(params)
  end

end