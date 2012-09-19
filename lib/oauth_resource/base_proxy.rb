class OauthResource::BaseProxy
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :InstanceClassMethods

  include InstanceClassMethods

  attr_reader :requester

  # Delegate All Class Attributes to the parent
  delegate  :client,
            :client_id,
            :client_secret,
            :site,
            :resource_name,
            :path,
            :format,
            :include_root_in_json,
            :connection,
            :permitted_attributes,
            :params,
            :parent,
            :joiner,
            to: :requester

  # Initialize the Proxy
  def initialize(requester)
    @requester = requester
    copy_instance_variables!
    determine_requester!
    clone_missing_methods!
  end

  private

  # Types
  def is_resource?
    requester.is_a?(Class) && (requester.ancestors.collect(&:to_s).include?("OauthResource::Base") || requester.name == "OauthResource::Base")
  end

  def is_instance?
    requester.is_a?(OauthResource::Base)
  end

  def is_proxy?
    requester.is_a?(OauthResource::BaseProxy)
  end

  # Clone Missing Methods to Proxy Class!
  def clone_missing_methods!
    methods = if is_resource?
                OauthResource::Base.methods + OauthResource::Base.private_methods
              elsif is_instance?
                OauthResource::Base.instance_methods + OauthResource::Base.private_instance_methods
              elsif is_proxy?
                OauthResource::BaseProxy.methods + OauthResource::BaseProxy.private_methods + OauthResource::BaseProxy.instance_methods + OauthResource::BaseProxy.private_instance_methods
              end
    methods = requester.methods + requester.private_methods - methods - self.methods - self.private_methods

    methods.each do |m|
      instance_eval(requester.method(m).source)
    end

  end

  def copy_instance_variables!
    requester.instance_variables.each do |attr|
      self.instance_variable_set attr, requester.instance_variable_get(attr)
    end
  end

  def determine_requester!

    if is_resource?
      self.extend(OauthResource::Base::Resource)
      self.class.send(:define_method, :new) do |*args|
        requester.new(*args)
      end

    elsif is_instance?
      self.extend(OauthResource::Base::Instance)
      initialize(requester.attributes, requester.init_options)

    elsif is_proxy?
      clone_missing_methods! # Clones the missing methods from the existing proxy!
      @requester = requester.requester
      determine_requester!

    else
      raise OauthResource::Error::InvalidObject, 'Object is not oauth_resource'

    end

  end

end