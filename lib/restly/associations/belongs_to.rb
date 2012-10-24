class Restly::Associations::BelongsTo < Restly::Associations::Base

  def find_with_parent(parent, options)
    options.reverse_merge!(self.options)
    association_class = polymorphic ? [@namespace, instance.send("#{name}_type")] : self.association_class
    association_class = authorize(association_class, options[:authorize])
    instance = association_class.find(parent.attributes["#{name}_id"])
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

  def collection?
    false
  end

end