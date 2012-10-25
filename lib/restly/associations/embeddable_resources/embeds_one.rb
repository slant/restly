class Restly::Associations::EmbeddableResources::EmbedsOne < Restly::Associations::Base

  def collection?
    false
  end

  def embedded?
    true
  end

end