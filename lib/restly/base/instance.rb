module Restly::Base::Instance
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern
  autoload :Actions
  autoload :Attributes
  autoload :Persistence
  autoload :WriteCallbacks
  autoload :Comparable
  autoload :ErrorHandling

  include Restly::Base::GenericMethods
  include Actions
  include Attributes
  include Persistence
  include WriteCallbacks
  include Comparable
  include ErrorHandling

  included do
    attr_reader :init_options, :response, :errors
    delegate :spec, to: :resource
  end

  def initialize(attributes = nil, options = {})

    @init_options = options
    @attributes = HashWithIndifferentAccess.new
    @association_cache = {}
    @association_attributes = HashWithIndifferentAccess.new
    @aggregation_cache = {}
    @attributes_cache = {}
    @previously_changed = {}
    @changed_attributes = {}
    @errors = ActiveModel::Errors.new(self)

    ActiveSupport::Notifications.instrument("load_instance.restly", instance: self) do

      run_callbacks :initialize do

        @readonly = options[:readonly] || false
        set_response options[:response] if options[:response]
        self.attributes = attributes if attributes
        @loaded = options.has_key?(:loaded) ? options[:loaded] : true
        self.connection = options[:connection] if options[:connection].is_a?(OAuth2::AccessToken)

      end

      @initialized = true

    end
  end

  def loaded?
    !!@loaded
  end

  def initialized?
    !!@initialized
  end

  def connection
    @connection || resource.connection
  end

  def connection=(val)
    @connection = val
  end

  def path=(val)
    @path = val
  end

  def path
    if @path
      @path
    elsif path_from_response
      path_from_response
    elsif send self.finder
      [self.class.path, send(self.finder)].join('/')
    else
      self.class.path
    end
  end

  def to_param
    id.to_s
  end

  private

  def set_response(response)
    raise Restly::Error::InvalidResponse unless response.is_a? OAuth2::Response
    @response = response
    if response.try(:body)
      if response_has_errors?(response)
        set_errors_from_response
      else
        set_attributes_from_response
      end
    end
  end

  def path_from_response
    response.response.env[:url].try(:path).try(:gsub, /\.\w+$/,'')
  rescue
    nil
  end

  def parsed_response(response=self.response)
    return {} unless response
    parsed = response.parsed || {}
    if parsed.is_a?(Hash) && parsed[resource_name]
      parsed[resource_name].with_indifferent_access
    elsif parsed.is_a?(Hash)
      parsed.with_indifferent_access
    else
      parsed
    end
  end

end
