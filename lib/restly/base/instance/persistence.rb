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
    self.class.send :instance_from_response, connection.get(path, force: true)
  end

end
