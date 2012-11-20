module Restly::Base::Resource::Finders

  def find(id, *args)
    options = args.extract_options!

    #params[pagination_options[:params][:page]] = options[:page] if pagination
    instance_from_response connection.get(path_with_format(id), params: params)
  end

  def all
    collection_from_response connection.get(path_with_format, params: params)
  end

  def create(attributes = nil, options = {})
    instance = self.new(attributes, options)
    instance.save
  end

  def collection_from_response(response)
    ActiveSupport::Notifications.instrument("load_collection.restly", model: name) do
      raise Restly::Error::InvalidResponse unless response.is_a? OAuth2::Response
      Restly::Collection.new resource, nil, response: response
    end
  end

  def instance_from_response(response)
    ActiveSupport::Notifications.instrument("load_instance.restly", model: name) do
      new(nil, response: response, connection: connection)
    end
  end

  alias_method :from_response, :instance_from_response

end