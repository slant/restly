module Restly::Base::Instance::Persistence

  def exists?
    return false unless id

    begin
      @response = connection.get(path, force: true) unless @response.status.to_i < 400

    rescue OAuth2::Error => e
      @response = e.response

    end

    status = @response.status.to_i
    status < 400 && status >= 200

  end

  def persisted?
    exists? && !changed?
  end

  def new_record?
    !exists?
  end

  def reload!
    return unless initialized? && loaded?
    raise Restly::Error::MissingId, "Cannot reload #{resource_name}, either it hasn't been created or it is missing an ID." unless exists?
    @loaded = true
    set_attributes_from_response connection.get(path_with_format, force: true)
    self
  end

  def load!
    return unless initialized? && loaded?
    raise Restly::Error::MissingId, "Cannot load #{resource_name}, either it hasn't been created or it is missing an ID." unless exists?
    @loaded = true
    set_attributes_from_response connection.get(path_with_format)
    self
  end


end
