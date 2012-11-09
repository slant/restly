module Restly::Error

  class StandardError < ::StandardError

    def message
      defined?(IRB) ? super.red : super
    end

  end

  errors = %w{
    RecordNotFound
    InvalidClient
    InvalidObject
    InvalidConnection
    MissingId
    InvalidSpec
    InvalidField
    AssociationError
  }

  errors.each do |error|
    const_set(error.to_sym, Class.new(StandardError))
  end

end