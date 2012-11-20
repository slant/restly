module Restly::Collection::ErrorHandling
  extend ActiveSupport::Concern

  def response_has_errors?(response=self.response)
    @response.status >= 400 ||
      (parsed_response(response).is_a?(Hash) &&
        (parsed_response(response)[:errors] || parsed_response(response)[:error]))
  end

  def set_errors_from_response(response = self.response)
    if (error = parsed_response(response)[:errors] || parsed_response(response)[:error])
      @errors << error
    end
    replace []
  end

end