module ModelAdditions

  # Model From Options
  def model_from_opts(resource, opts)

    # Base Model
    model = opts[:class_name] || resource.to_s.camelize

    # Namespace
    namespace = opts[:namespace] || self.name.gsub(/::\w+$/, '')
    model = [namespace, model].compact.join('::')

    # Polymorphic
    if opts[:polymorphic]
      polymorphic_type = send(:"#{resource}_type")
      model = [model, polymorphic_type].join('::')
    end

    # Constantize
    model = model.constantize

  end

end
