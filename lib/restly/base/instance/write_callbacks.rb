module Restly::Base::Instance::WriteCallbacks
  extend ActiveSupport::Concern

  included do
    before_save :format_request
  end

  private

  def format_request
    @request_body = case format.to_sym
                      when :json
                        savable_resource.to_json
                      when :xml
                        savable_resource.to_xml
                      else
                        savable_resource.to_param
                    end
  end

  def savable_resource
    {resource_name => attributes_with_present_values(writeable_attributes)}
  end

  def attributes_with_present_values(attributes=self.attributes)
    attributes.as_json.reduce({}) do |hash, (key, val)|
      if val.is_a?(Hash)
        hash[key] = attributes_with_present_values(val)
      elsif val.present? && key.to_sym != :id
        hash[key] = val
      end
      hash
    end
  end

  def writeable_attributes(attributes=self.attributes)
    maa = mass_assignment_authorizer(:default)

    if maa.is_a? ActiveModel::MassAssignmentSecurity::BlackList
      attributes.reject{ |key, val| maa.map(&:to_sym).include?(key.to_sym) }

    elsif maa.is_a? ActiveModel::MassAssignmentSecurity::WhiteList
      attributes.select{ |key, val| maa.map(&:to_sym).include?(key.to_sym) }

    end
  end


end