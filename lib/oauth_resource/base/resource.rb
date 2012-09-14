module OauthResource::Base::Resource
  extend ActiveSupport::Autoload
  autoload :Finders

  include OauthResource::Base::GenericMethods
  include Finders

  # OPTIONS FOR /:path
  # Fetches the spec of a remote resource
  def spec
    @spec ||= connection.request(:options, path).parsed || {}
  end

end