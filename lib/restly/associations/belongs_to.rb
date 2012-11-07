class Restly::Associations::BelongsTo < Restly::Associations::Base

  def load(parent, options)
    if polymorphic
      set_polymorphic_class(parent).load(parent, options)
    else
      # Merge Options
      options.reverse_merge!(self.options)

      # Authorize and Set Path
      association = authorize(options[:authorize])
      association.load_instance(parent)
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