module OauthResource::Relationships::Builder

  def build(relationship, opts)

    # Base Model
    model = opts[:class_name] || relationship.to_s.singularize.camelize

    # Namespace
    namespace = opts[:namespace] || self.class.name.gsub(/::\w+$/, '')
    model = [namespace, model].compact.join('::')

    # Polymorphic Relationships
    if opts[:polymorphic]
      polymorphic_type = send(:"#{resource}_type")
      model = [namespace, polymorphic_type].compact.join('::')
    end

    # Constantize
    model = model.constantize

    # Auto-authorization, fail with error!
    if (!model.authorized? && self.respond_to?(:authorized?) && self.authorized?) || (connection = opts[:authorize])
      model.authorize(connection || self.connection)
    else
      model
    end

  end

end