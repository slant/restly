module Restly::Base::Instance::Persistence

  def exists?
    return false unless id

    begin
      @response ||= connection.get(path, force: true)

    rescue OAuth2::Error => e
      @response = e.response

    end

    status = @response.status.to_i
    status < 300 && status >= 200

  end

  def persisted?
    exists? && !changed?
  end

  def new_record?
    !exists?
  end

  def reload!
    raise Restly::Error::MissingId, "Cannot reload #{resource_name}, either it hasn't been created or it is missing an ID." unless new_record?
    set_attributes_from_response connection.get(path_with_format, force: true)
    @loaded = true
    self
  end

  alias :load! :reload!

end
