class Restly::Associations::HasMany < Restly::Associations::Base

  attr_reader :joiner

  def initialize(owner, name, options={})
    @joiner = options.delete(:through)
    super
  end

  def load(parent, options)
    options.reverse_merge!(self.options)
    association_class = polymorphic ? [@namespace, instance.send("#{name}_type")] : self.association_class
    association_class = authorize(association_class, options[:authorize])
    collection = association_class.with_params("with_#{parent.resource_name}_id" => parent.id).all # (parent.attributes["#{name}_id"])
    collection.select{|i| i.attributes["#{parent.resource_name}_id"] == parent.id }
    Restly::Proxies::Associations::Collection.new(collection, parent)
  end

  def collection?
    true
  end

end