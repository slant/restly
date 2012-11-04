class Restly::Associations::BelongsTo < Restly::Associations::Base

  def load(parent, options)
    if polymorphic
      set_polymorphic_class(parent).load(parent, options)
    else
      super(parent, options)
    end
  end

  private

  def set_polymorphic_class(parent)
    duplicate = self.dup
    duplicate.instance_variable_set(:@association_class, parent.send("#{name}_type"))
    duplicate.instance_variable_set(:@polymorphic, false)
    duplicate
  end

end