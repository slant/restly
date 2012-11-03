class Restly::Proxies::Associations::Collection < Restly::Proxies::Base

  attr_reader :parent, :joiner

  def initialize(array, parent, joiner=nil)
    array.map!{ |instance| Restly::Proxies::Associations::Instance.new(instance, parent, joiner) }
    super(array)
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