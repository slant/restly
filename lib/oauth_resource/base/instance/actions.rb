module OauthResource::Base::Instance::Actions

  def save
    @previously_changed = changes
    @changed_attributes.clear
    update_or_create
  end

  def delete
    connection.delete(path_with_format, params: params)
    false
    freeze
  end

  def update_or_create
    if new_record?
      @attributes = self.class.create(attributes).attributes
    else
      connection.put(path_with_format, body: attributes, params: params)
    end
    self
  end

end