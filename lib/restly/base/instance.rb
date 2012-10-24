module Restly::Base::Instance
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern
  autoload :Actions
  autoload :Attributes
  autoload :Persistence

  include Restly::Base::GenericMethods
  include Actions
  include Attributes
  include Persistence

  included do
    attr_reader :init_options, :response
    delegate :spec, to: :klass
  end

  def initialize(attributes = nil, options = {})

    @init_options = options
    @attributes = HashWithIndifferentAccess.new
    @association_cache = {}
    @aggregation_cache = {}
    @attributes_cache = {}
    @previously_changed = {}
    @changed_attributes = {}

    run_callbacks :initialize do

      @readonly = options[:readonly] || false
      set_response options[:response] if options[:response]
      @loaded = options.has_key?(:loaded) ? options[:loaded] : true
      self.attributes = attributes if attributes
      self.connection = options[:connection] if options[:connection].is_a?(OAuth2::AccessToken)
      self.path = if response && response.response.env[:url]
                    response.response.env[:url].path.gsub(/\.\w+$/,'')
                  elsif respond_to?(:id) && id
                    [path, id].join('/')
                  else
                    klass.path
                  end
    end

  end

  def pry_in
    binding.pry
  end

  def set_response(response)
    raise Restly::Error::InvalidResponse unless response.is_a? OAuth2::Response
    @response = response
    if response.try(:body)
      set_attributes_from_response
      stub_associations_from_response
    end
  end

  def connection
    @connection || self.class.connection
  end

  def connection=(val)
    @connection
  end

  # Todo: Needed?
  def instance
    self
  end

  def klass
    self.class
  end

end