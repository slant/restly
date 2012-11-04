class Restly::Proxies::Associations::Collection < Restly::Proxies::Base

  attr_reader :parent, :joiner

  def initialize(collection, parent, joiner=nil)
    collection.map!{ |instance| Restly::Proxies::Associations::Instance.new(instance, parent, joiner) }
    super(collection)
    @parent = parent
    @joiner = joiner
  end

  def <<(instance)
    collection = super
    instance = create(instance.attributes) unless instance.persisted?
    if joiner
      joiner.create("#{parent.resource_name}_id" => parent.id, "#{instance.resource_name}_id" => instance.id)
    elsif parent
      instance.update_attributes("#{parent.resource_name}_id" => parent.id)
    end
    collection
  end

end