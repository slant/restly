module OauthResource::Base::ResourceActions

  include OauthResource::Base::GenericMethods

  def find(*args)
    params ||= {}
    options = args.extract_options!

    params[pagination_options[:params][:page]] = options[:page] if pagination
    readonly = options[:readonly]

    self.new(connection.get path, connection: connection)
  end

  def all
    self.new(connection.get path, connection: connection)
  end

  # OPTIONS FOR /:path
  # Fetches the spec of a remote resource
  def spec
    connection.request(:options, path).parsed
  end

  def private

  end

end