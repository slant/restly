module OauthResource::Base::Collection::Paginated
  
  def page(num)
    request_params ||=
    resource.with_params(params).all
  end

end