module OauthResource::Error

  class NotAnOauthResource < StandardError
  end

  class RecordNotFound < StandardError
  end

  class WrongResourceType < StandardError
  end

  class InvalidParentAssociation < StandardError
  end

  class InvalidJoinerAssociation < StandardError
  end

  class InvalidObject < StandardError
  end

end