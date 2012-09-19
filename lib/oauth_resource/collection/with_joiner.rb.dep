module OauthResource::Base::Collection::WithJoiner

  def self.extended(base)
    # base.send(:alias, :build :new)
  end

  def <<(object)
    raise OauthResource::Error::WrongResourceType, "#{object.resource.class} must be a #{resource.class}" unless object.resource.class == resource.class
    joiner.create(joiner_attrs object)
    self
  end

  def create(attrs={})
    joiner.create(joiner_attrs object)
    super
  end

  def new(attrs={})
    joiner.new(joiner_attrs object)
    super
  end

  def joiner_attrs(object)
    { "#{parent.resource_name}_id".to_sym => parent.id, "#{object.resource_name}_id".to_sym => object.id }
  end

end