class Requester

  def initialize(env, &block)
    @env = env
    logger.debug "#{@env[:method].upcase} #{@env[:url].path}"
    @action = instance_eval(&block)
  end

  def response
    return @response if @response
    @response ||= case format
                 when "json"
                   @action.to_json
                 when "xml"
                   @action.to_xml
                 else
                   @action.to_param
               end
    logger.debug "  response body: #{@response}" if @response.present?
    @response
  end

  def response_headers
    return @response_headers if @response_headers
    @response_headers ||= {
      "Content-Type" => content_type
    }
    logger.debug "  response headers: #{@response_headers}"
    @response_headers
  end

  private

  def format
    return @format if @format
    @format ||= params[:format]
    logger.debug "  format: #{@format}"
    @format
  end

  def model
    ["SampleObjects", params[:model].try(:classify)].join("::").try(:constantize)
  end

  def params
    return @params if @params
    @params ||= @env[:params].try(:with_indifferent_access) || {}
    logger.debug "  request params: #{@params}" if @params.present?
    @params
  end

  def data
    model_body   = parsed[model.name.underscore] || {}
    model_params = params[model.name.underscore] || {}
    model_params.merge(model_body)
  end

  def parsed
    return {} unless body.present?
    case format
      when "json"
        JSON.parse(body)
      when "xml"
        Hash.from_xml(body)
      else
        {}
    end
  end

  def content_type
    case format
      when "json"
        "application/json"
      when "xml"
        "application/xml"
      else
        "text/plain"
    end
  end

  def body
    return @body if @body
    @body ||= @env[:body]
    puts "  request body: #{@body}" if @body.present?
    @body
  end

end