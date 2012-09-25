module OauthResource::Base::Instance
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern
  autoload :Actions
  autoload :Attributes
  autoload :Persistence

  include OauthResource::Base::GenericMethods
  include Actions
  include Attributes
  include Persistence

  included do
    attr_reader :init_options, :response
  end

  def initialize(attributes = nil, options = {})
    @loaded = false
    @init_options = options
    @attributes = {}
    @association_cache = {}
    @aggregation_cache = {}
    @attributes_cache = {}
    @readonly = options[:readonly] || false
    @previously_changed = {}
    @changed_attributes = {}
    set_response options[:response] if options[:response]
    set_attributes_from_response if response.try(:body)
    @loaded = true
    self.attributes = attributes if attributes
    self.connection = options[:connection] if options[:connection].is_a?(OAuth2::AccessToken)
    self.path = response.response.env[:url].path if response
  end

  def set_response(response)
    raise OauthResource::Error::InvalidResponse unless response.is_a? OAuth2::Response
    @response = response
  end

  def instance
    self
  end

  def klass
    self.class
  end

end