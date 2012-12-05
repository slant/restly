module Restly::Base::Includes
  extend ActiveSupport::Concern

  included do
    class_attribute :finder, :current_specification, instance_writer: false
  end

  module ClassMethods

    # Delegate stuff to client
    delegate :site, :site=, :format, :format=, to: :client

    def client
      return @client if @client
      @client = Restly::Client.new(nil, nil)
      @client.resource = self
      @client
    end

    def client=(client)
      raise Restly::Error::InvalidClient, "Client is invalid!" unless client.is_a?(Restly::Client)
      @client = client
      @client.resource = self
      @client
    end

    def find_by(field)
      self.finder = field
    end

    def has_specification
      self.current_specification = Restly::Base::Resource::Specification.new(self)

      self.fields = current_specification.fields

      self._accessible_attributes = accessible_attributes_configs.dup
      self._protected_attributes =  protected_attributes_configs.dup

      (self._accessible_attributes ||= {})[:default] = current_specification.accessible_attributes
      (self._protected_attributes ||= {})[:default] = current_specification.protected_attributes

      self._active_authorizer = current_specification.active_authorizer
    end

    def connection
      connection = @connection || Restly::Connection.tokenize(client, current_token)
      connection.cache ||= cache
      connection.cache_options = cache_options unless connection.cache_options.present?
      connection
    end

    def connection=(connection)
      raise InvalidConnection, "#{connection} is not a valid Restly::Connection" unless connection.is_a?(Restly::Connection)
      @connection = connection
    end

    def param_key
      resource_name
    end

  end

end