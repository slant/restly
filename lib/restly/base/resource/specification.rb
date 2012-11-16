class Restly::Base::Resource::Specification
  extend ActiveSupport::Autoload

  autoload :Fields
  autoload :MassAssignmentSecurity

  attr_reader :model

  delegate :authorize, :client_token, :path, to: :model

  def initialize(model)
    @model = model
    @specification = HashWithIndifferentAccess.new
    @retry_count = 0
  end

  def accessible_attributes
    @accessible_attributes ||= MassAssignmentSecurity::AccessibleAttributes.new(self)
  end

  def protected_attributes
    @protected_attributes ||= MassAssignmentSecurity::ProtectedAttributes.new(self)
  end

  def active_authorizer
    @active_authorizer ||= MassAssignmentSecurity::DynamicAuthorizer.new(self)
  end

  def fields
    @fields ||= Fields.new(self)
  end

  def [](key)
    reload_specification! unless @specification[key].present?
    @specification[key]
  end

  private

  def reload_specification!
    parsed_response = authorize(client_token).connection.request(:options, path).parsed
    @specification = parsed_response.with_indifferent_access if parsed_response.present?
  rescue OAuth2::Error
    false
  end

  def method_missing(method, *args, &block)
    if self[method]
      self[method]
    else
      @retry_count = 0
      super(method, *args, &block)
    end
  end

  def respond_to_missing?(method, include_private=false)
    model.respond_to?(method)
  end

end