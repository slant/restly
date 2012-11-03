class Restly::Associations::EmbeddableResources::EmbedsOne < Restly::EmbeddedAssociations::Base

  def collection?
    false
  end

  def embedded?
    true
  end

end