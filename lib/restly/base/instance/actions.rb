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
    response = connection.delete(path_with_format, params: params)
    freeze
    response.status < 300
  end

  def destroy
    run_callbacks :destroy do
      delete
    end
  end

  private

  def update
    run_callbacks :update do
      set_response(connection.put path_with_format, body: @request_body, params: params)
    end
  end

  def create
    run_callbacks :create do
      set_response(connection.post path_with_format, body: @request_body, params: params)
    end
  end

end