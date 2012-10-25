class Restly::Associations::BelongsTo < Restly::Associations::Base

  def load(parent, options)
    options.reverse_merge!(self.options)
    association_class = polymorphic ? [@namespace, instance.send("#{name}_type")] : self.association_class
    authorized_class = authorize(association_class, options[:authorize] || parent.connection)
    instance = authorized_class.find(parent.attributes["#{name}_id"])
    Restly::Proxies::Associations::Instance.new(instance, parent)
  end

  def collection?
    false
  end

end