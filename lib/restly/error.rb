module Restly::Error

  class StandardError < ::StandardError

    def message
      super.red
    end

  end

  errors = %w{
    RecordNotFound
    WrongResourceType
    InvalidParentAssociation
    InvalidJoinerAssociation
    InvalidObject
    InvalidToken
    InvalidConnection
    MissingId
    InvalidSpec
    AssociationError
  }

  errors.each do |error|
    const_set(error.to_sym, Class.new(StandardError))
  end

end