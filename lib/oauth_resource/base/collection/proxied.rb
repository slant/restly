module OauthResource::Base::Collection::Proxied

  def <<(resource)
    new_join = joiner.new(@relationship => resource)
    new_join.save
  end

  def create(attrs={})
  end

  def build
  end


end