module Restly::Error

  class NotAnRestly < StandardError
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

  class InvalidToken < StandardError
  end

  class InvalidConnection < StandardError
  end

  class InvalidSpec < StandardError
  end

end