module OauthResource::Base::Instance
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern
  autoload :Actions
  autoload :Attributes
  autoload :Persistence

  include OauthResource::Base::GenericMethods
  include Actions
  include Attributes

  included do
    attr_reader :init_options, :response
  end

  def initialize(attributes = nil, options = {})
    @init_options = options
    @attributes = {}
    @association_cache = {}
    @aggregation_cache = {}
    @attributes_cache = {}
    @readonly = options[:readonly] || false
    @previously_changed = {}
    @changed_attributes = {}
    set_response options[:response] if options[:response]
    @relation = options[:relation]
    self.attributes = attributes if attributes
    set_attributes_from_response if response.try(:body)
    self.connection = options[:connection] if options[:connection].is_a?(OAuth2::AccessToken)
    #self.path = [path, id].join('/')
    #self.path = nil unless exists?
  end

  def set_response(response)
    raise OauthResource::Error::InvalidResponse unless response.is_a? OAuth2::Response
    @response = response
  end

  def method_missing(m, *args, &block)
    if !!(/(?<attr>\w+)=$/ =~ m.to_s) && attribute_permitted?(attr) && args.size == 1
      send("#{attr}_will_change!".to_sym) unless args.first == @attributes[attr.to_sym]
      @attributes[attr.to_sym] = args.first
    elsif !!(/(?<attr>\w+)=?$/ =~ m.to_s) && attribute_permitted?(attr)
      attributes[attr.to_sym]
    else
      raise NoMethodError, "undefined method #{m} for #{klass}"
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    !!(/(?<attr>\w+)=?$/ =~ method_name.to_s) && attribute_permitted?(attr)
  end

  def instance
    self
  end

  def klass
    self.class
  end

end