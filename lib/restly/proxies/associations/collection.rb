class Restly::Proxies::Associations::Collection < Restly::Proxies::Base

  attr_reader :parent, :joiner

  def initialize(receiver, parent, joiner=nil)
    super(receiver)
    @parent = parent
    @joiner = joiner
  end

  def <<(instance)
    collection = receiver << instance
    instance.save unless instance.persisted
    if joiner
      joiner.create("#{parent.resource_name}_id" => parent.id, "#{instance.resource_name}_id" => instance.id)
    elsif parent
      instance.update_attributes("#{parent.resource_name}_id" => parent.id)
    end
    collection
  end

end