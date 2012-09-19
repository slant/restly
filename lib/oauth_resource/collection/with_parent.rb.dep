module OauthResource::Base::Collection::WithParent

  def self.extended(base)
    base.alias_method :build, :new
  end

  def <<(object)
    raise OauthResource::Error::WrongResourceType, "#{object.resource.class} must be a #{resource.class}" unless object.resource.class == resource.class
    object.update_attributes(parent_attrs)
    self
  end

  def create(attrs={})
    attrs.merge!(parent_attrs)
    super
  end

  def new(attrs={})
    attrs.merge!(parent_attrs)
    super
  end

  def parent_attrs
    { "#{parent.resource_name}_id".to_sym => parent.id }
  end

end