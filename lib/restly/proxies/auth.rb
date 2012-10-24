class Restly::Proxies::Auth < Restly::Proxies::Base

  def initialize(receiver, token)
    super(receiver)
    self.connection = Restly::Connection.tokenize(client, token)
    connection.cache_options = receiver.cache_options
  end

end