module OauthResource::Base::Instance
  extend ActiveSupport::Autoload
  autoload :Actions
  autoload :Attributes
  autoload :Persistence

  include OauthResource::Base::GenericMethods
  include Actions
  include Attributes

  attr_reader :init_options, :response

  def initialize(attributes = nil, options = {})
    @init_options = options
    @attributes = attributes || {}
    @association_cache = {}
    @aggregation_cache = {}
    @attributes_cache = {}
    @readonly = options[:readonly] || false
    @previously_changed = {}
    @changed_attributes = {}
    set_response options[:response] if options[:response]
    @relation = options[:relation]
    set_attributes_from_response if response.try(:body)
    #self.path = [path, id].join('/')
    #self.path = nil unless exists?
  end

  def set_response(response)
    raise OauthResource::Error::InvalidResponse unless response.is_a? OAuth2::Response
    @response = response
  end

  def set_attributes_from_response
    parsed = response.parsed
    parsed = parsed[resource_name] if parsed[resource_name]
    self.attributes = parsed
  end

  def method_missing(m, *args, &block)
    if !!(/(?<attr>\w+)=$/ =~ m.to_s) && attribute_permitted?(attr) && args.size == 1
      send("#{attr}_will_change!".to_sym) unless args.first == @attributes[attr.to_sym]
      @attributes[attr.to_sym] = args.first
    elsif !!(/(?<attr>\w+)=?$/ =~ m.to_s) && attribute_permitted?(attr)
      attributes[attr.to_sym]
    else
      raise NoMethodError,"undefined method `#{m}' for #{klass}"
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    !!(/(?<attr>\w+)=?$/ =~ m.to_s) && attribute_permitted?(attr)
  end

end