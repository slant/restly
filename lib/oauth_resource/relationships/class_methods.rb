module OauthResource::Relationships::ClassMethods

  def belongs_to_resource(resource, opts={})
    "#{name}::Instance".constantize.send :define_method, resource do
      # klass determined by class_name or from resource name
      model = opts[:class_name] || resource.to_s.camelize

      # Determine the base namespace
      namespace = opts[:namespace] || self.resource.class.name.gsub(/::\w+$/, '')
      model = [namespace, model].compact.join('::')

      # Polymorphism
      if opts[:polymorphic]
        polymorphic_type = send(:"#{resource}_type")
        model = [model, polymorphic_type].join('::')
      end

      # Constantize the Model Name
      model = model.constantize

      # Authorize the Oauth Resource
      auth_token = opts[:authorize] ? (self.resource.connection rescue nil) : nil

      model.authorize( auth_token, path: opts[:path] ).find(send(:"#{resource}_id"))
    end
  end

  def has_one_resource(resource, opts={})
    "#{name}::Instance".send :define_method, resource do
      model = opts[:class_name] || resource.to_s.camelize.constantize
      path = opts[:absolute_path] ? opts[:path] : [self.resource.path, id, (opts[:path] || resource.to_s) ].join('/')
      model.authorize( self.resource.connection, path: path ).all.first
    end
  end

  def has_many_resources(resources, opts={})
    "#{name}::Instance".send :define_method, resources do
      model = opts[:class_name] || resources.to_s.singularize.camelize.constantize
      path = opts[:absolute_path] ? opts[:path] : [self.resource.path, id, (opts[:path] || resources.to_s) ].join('/')
      model.authorize( self.resource.connection, path: path ).all
    end
  end

end