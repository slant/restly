module OauthResource::Base::Queries
  extend ActiveSupport::Concern

  included do ; end

  # GET's FROM /:path
  # Fetches the index of the remote resource
  def all
    connection.get(path, params: params)
    collection_for_response response
  end

  # GET's FROM /:path/:id
  # Fetches A Remote Resource
  def find(id)
    response = connection.get( path(id), params: params)
    raise OauthResource::Error::RecordNotFound, "Could not find #{self.class} with id=#{id}" if response.error
    instance_for_response response
  end

  # POST's TO /:path
  # Creates a Remote Resource
  def create(attrs={})
    connection.post(path, body: attrs, params: params)
  end

  # OPTIONS FOR /:path
  # Fetches the spec of a remote resource
  def spec
    connection.request(:options, path).parsed.extend OauthResource::Base::ObjectMethods
  end

  # Initializes a resource locally when the spec is known.
  def new
    if spec
      spec.attributes.each do |k|
        self.send("#{k}=", nil)
      end
    else
      instance_for_response({}, parsed: false, error: false)
    end
  end

  alias_method :build, :new

end