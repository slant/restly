module Restly::Error

  class StandardError < ::StandardError

    def message
      super.red
    end

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

  class MissingId < StandardError
  end

  class InvalidSpec < StandardError
  end

end