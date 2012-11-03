class Restly::EmbeddedAssociations::Base < Restly::Associations::Base

  def nested?
    false
  end

end