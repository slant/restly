module OauthResource::Relationships::ClassMethods

  def belongs_to_resource(relationship, opts={})

    parent_class.send :define_method, relationship do
      self.extend OauthResource::Relationships::Builder
      self.build(relationship, opts).find(send(:"#{relationship}_id"))
    end

  end

  def has_one_resource(relationship, opts={})

    # Define Relationship
    parent_class.send :define_method, relationship do
      self.extend OauthResource::Relationships::Builder
      opts[:path] ||= rel_path(id, relationship)
      self.build(relationship, opts).all.first
    end

  end

  def has_many_resources(relationship, opts={})

    # Define Relationship
    parent_class.send :define_method, relationship do
      opts[:path] ||= rel_path(id, relationship)
      self.build(relationship, opts).all
    end

  end

  private

  def parent_class
    if self.const_defined?("Instance") && "#{name}::Instance".constantize.superclass == OauthResource::Base::Instance
      "#{name}::Instance".constantize
    else
      self
    end
  end

end