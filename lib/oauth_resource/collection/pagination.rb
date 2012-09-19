module OauthResource::Base::Collection::Pagination

  def page(num)
    resource.with_params(page: num, per_page: per_page).all.paginate(page: num, per_page: per_page)
  end

  def current_page
    pagination[:current_page] || pagination[:page]
  end

  def per_page
    @pagination_opts[:per_page] || pagination[:per_page]
  end

  def response_per_page
    pagination[:per_page]
  end

  def total_pages
    pagination[:total_pages]
  end

  def total_entries
    pagination[:total_entries]
  end

  private

  def pagination
    parsed = @response.parsed || {}
    pagination = parsed[:pagination] || parsed
    pagination.select!{ |k,v| /page|current_page|entries|total_entries|per_page|total_pages|total/ =~ k.to_s }
    pagination.with_indifferent_access
  end

end