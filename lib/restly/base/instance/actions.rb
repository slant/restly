module Restly::Base::Instance::Actions

  def save
    run_callbacks :save do
      @previously_changed = changes
      @changed_attributes.clear
      new_record? ? create : update
    end
    self
  end

  def delete
    run_callbacks :delete do
      response = connection.delete(path_with_format, params: params)
      false
      freeze
    end
    response.status < 300
  end

  private

  def update
    run_callbacks :update do
      set_attributes_from_response(connection.put path_with_format, body: @request_body, params: params)
    end
  end

  def create
    run_callbacks :create do
      set_attributes_from_response(connection.post path_with_format, body: @request_body, params: params)
    end
  end

end