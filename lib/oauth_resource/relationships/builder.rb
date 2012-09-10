module OauthResource::Relationships::Builder

  def build(relationship, opts)

    # Base Model
    model = opts[:class_name] || relationship.to_s.camelize

    # Namespace
    namespace = opts[:namespace] || self.class.name.gsub(/::\w+(::Instance)?$/, '')
    model = [namespace, model].compact.join('::')

    # Polymorphic Relationships
    if opts[:polymorphic]
      polymorphic_type = send(:"#{resource}_type")
      model = [namespace, polymorphic_type].compact.join('::')
    end

    # Constantize
    model = model.constantize

    # Auto-authorization, fail with error!
    if opts[:authorize] && (self.resource.connection rescue false)
      model.authorize( resource.connection, path: opts[:path] )
    elsif opts[:authorize]
      raise OauthResource::Error::NotAnOauthResource, "#{self.class.name} is not an oauth resource!"
    else
      model.authorize( nil, path: opts[:path] )
    end

  end

  def rel_path(*args)
    respond_to?(:path) ? path : ([self.class.name.underscore.pluralize] + args).join('/')
  end

end