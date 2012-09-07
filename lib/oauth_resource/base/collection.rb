require 'will_paginate/array'

class OauthResource::Base::Collection < Array

  def initialize( resource, response )
    self.extend OauthResource::Base::ObjectMethods
    super(response || [])
    self.resource = resource
  end

end
