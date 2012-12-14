module Restly::Error

  errors = %w{
    RecordNotFound
    InvalidClient
    InvalidObject
    InvalidConnection
    ConnectionError
    MissingId
    InvalidSpec
    InvalidField
    InvalidAssociation
    InvalidAttribute
    InvalidNestedAttribute
    AssociationError
    Unauthorized
  }

  errors.each do |error|
    const_set error.to_sym, Class.new(StandardError)
  end

end
