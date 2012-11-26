module Restly::Base::Instance::ErrorHandling
  extend ActiveSupport::Concern

  def append_error(field, error)
    self.errors.add field.to_sym, error
    if /(?<association>\w+)\.(?<attr>.+)/ =~ field && respond_to_association?(association)
      instance_eval(&association.to_sym).append_error(attr, error)
    end

  end

  private

  def response_has_errors?(response=self.response)
    @response.status >= 400 ||
      (parsed_response(response).is_a?(Hash) &&
        (parsed_response(response)[:errors] || parsed_response(response)[:error]))
  end

  def set_errors_from_response(response = self.response)

    response_errors = parsed_response(response)[:errors] || parsed_response(response)[:error]

    case response_errors

      when Hash
        response_errors.each do |name, error|
          case error

            when Array
              error.each { |e| append_error name, e }

            when String
              append_error name, error

          end

        end

      when Array
        response_errors.each { |error| append_error :base, error }

      when String
        append_error :base, response_errors

      when NilClass
        append_error :base, connection.status_string(response.status)

    end

    self.errors
  end

  def read_attribute_for_validation(attr)
    send attr
  end

  module ClassMethods

    def human_attribute_name(attr, options = {})
      attr.to_s.humanize
    end

    def lookup_ancestors
      [self]
    end

  end

end