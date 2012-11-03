module Restly::Associations::Modifiers

  # Modifiers
  def authorize(authorization = nil, association_class=self.association_class)
    duplicate = self.dup
    duplicate.instance_variable_set :@association_class, if (!association_class.authorized? && @owner.respond_to?(:authorized?) && @owner.authorized?) || authorization
                                                           association_class.authorize(authorization || @owner.connection)
                                                         else
                                                           association_class
                                                         end
    duplicate
  end

  def with_path(parent, path = nil, association_class=self.association_class)
    duplicate = self.dup
    duplicate.instance_variable_set :@association_class, if path
                                                           association_class.with_path(path)
                                                         else
                                                           association_class.with_path(association_resource_name, prepend: parent.path)
                                                         end
    duplicate
  end

end