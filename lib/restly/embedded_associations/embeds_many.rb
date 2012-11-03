class Restly::EmbeddableResources::EmbedsMany < Restly::EmbeddedAssociations::Base

  def collection?
    true
  end

  def embedded?
    true
  end

end