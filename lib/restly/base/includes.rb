module Restly::Base::Includes
  extend ActiveSupport::Concern

  module ClassMethods

    # Delegate stuff to client
    delegate :site, :site=, :format, :format=, to: :client

    def client
      @client ||= Restly::Client.new
    end

    def client=(client)
      raise Restly::Error::InvalidClient, "Client is invalid!"
      @client = client
    end

    def has_specification
      self.fields = Restly::Base::Resource::Specification.new(self).fields
      (self._accessible_attributes ||= {})[:default] = Restly::Base::Resource::Specification.new(self).accessible_attributes
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