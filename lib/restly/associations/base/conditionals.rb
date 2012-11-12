module Restly::Associations::Base::Conditionals

  # Conditionals
  def valid?(val)
    valid_instances = Array.wrap(val).reject{ |item| item.resource_name == association_class.resource_name }.empty?
    raise Restly::Error::InvalidObject, "#{val} is not a #{association_class}" unless valid_instances
  end

  def collection?
    false
  end

  def embedded?
    false
  end

  def nested?
    false
  end

end