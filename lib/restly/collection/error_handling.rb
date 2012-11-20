module Restly::Base::Instance::ErrorHandling
  extend ActiveSupport::Concern

  def set_errors_from_response(response = self.response)

    response_errors = parsed_response(response)[:errors] || parsed_response(response)[:error]

    case response_errors

      when Hash
        response_errors.each do |name, error|
          case error

            when Array
              error.each { |e| self.errors.add(name.to_sym, e) }

            when String
              self.errors.add(name.to_sym, error)

          end
        end

      when Array
        response_errors.each do |error|
          self.errors.add(:base, error)
        end

      when String
        self.errors.add(:base, response_errors)

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