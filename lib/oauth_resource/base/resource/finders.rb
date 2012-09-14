module OauthResource::Base::Resource::Finders

  def find(*args)
    params ||= {}
    options = args.extract_options!

    #params[pagination_options[:params][:page]] = options[:page] if pagination
    response = connection.get path_with_format(args.first)
    resource.new(nil, connection: connection, response: response)
  end

  def all
    self.new(connection.get path, connection: connection)
  end

end