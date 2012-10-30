class Restly::Associations::BelongsTo < Restly::Associations::Base

  def load(parent, options)
    if polymorphic
      set_polymorphic_class(parent).load(parent, options)
    else
      super(parent, options)
    end
  end

  def set_polymorphic_class(parent)
    duplicate = self.dup
    duplicate.instance_variable_set(:@association_class, parent.send("#{name}_type"))
    duplicate.instance_variable_set(:@polymorphic, false)
    duplicate
  end

  def with_path(parent, path = nil, association_class=self.association_class)
    duplicate = self.dup
    duplicate.instance_variable_set :@association_class, if path
                                                           association_class.with_path(path)
                                                         else
                                                           association_class
                                                         end
    duplicate
  end

  def collection?
    false
  end

end