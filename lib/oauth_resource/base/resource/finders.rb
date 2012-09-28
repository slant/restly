module OauthResource::Base::Resource::Finders

  def find(*args)
    options = args.extract_options!

    #params[pagination_options[:params][:page]] = options[:page] if pagination
    instance_from_response connection.get(path_with_format(args.first), params: params)
  end

  def all
    collection_from_response connection.get(path_with_format, params: params)
  end

  def create(attributes = nil, options = {})
    instance = self.new(attributes, options)
    instance_from_response connection.post(path_with_format, body: instance.attributes, params: params)
  end

  private

  def collection_from_response(response)
    raise OauthResource::Error::InvalidResponse unless response.is_a? OAuth2::Response
    OauthResource::Collection.new self, nil, response: response
  end

  def instance_from_response(response)
    new(nil, response: response, connection: connection)
  end

  alias_method :from_response, :instance_from_response

end