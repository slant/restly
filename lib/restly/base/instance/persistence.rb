module Restly::Base::Instance::Persistence

  def exists?
    status = @response.try(:status).to_i
    status < 300 && status >= 200
  end

  def persisted?
    exists? && !changed?
  end

  def new_record?
    !exists?
  end

  def reload!
    raise Restly::Error::MissingId, "Cannot reload #{resource_name}, either it hasn't been created or it is missing an ID." unless id
    set_attributes_from_response connection.get(path, force: true)
    @loaded = true
    self
  end

  alias :load! :reload!

end
