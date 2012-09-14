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
    if self.respond_to?(:authorized?) && self.authorized?
      model.authorize(connection)
    else
      model
    end

  end

end