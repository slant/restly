module Restly::Base::Instance::WriteCallbacks
  extend ActiveSupport::Concern

  included do
    extend ClassMethods

    class_attribute :request_builders
    self.request_builders = []

    build_request :attributes

  end

  def formatted_for_request

    case format.to_sym
      when :json
        built_for_request.to_json

      when :xml
        built_for_request.to_xml

      else
        built_for_request.to_param

    end

  end

  def built_for_request(resource_key=resource_name)

    attributes = request_builders.reduce(HashWithIndifferentAccess.new) do |attributes, builder|
      attributes.merge! builder.is_a?(Symbol) ? send(builder) : instance_eval(&builder)
    end

    maa = mass_assignment_authorizer(:default)

    if maa.is_a? ActiveModel::MassAssignmentSecurity::BlackList
      attributes.except! *maa.map(&:to_sym)

    elsif maa.is_a? ActiveModel::MassAssignmentSecurity::WhiteList
      attributes.slice! *maa.map(&:to_sym)

    end

    if resource_key
      { resource_key.to_sym => attributes.select { |k,v| v.present? } }
    else
      attributes.select { |k,v| v.present? }
    end

  end

  module ClassMethods

    private

    def build_request(symbol=nil, &block)
      self.request_builders << symbol || block
    end

  end


end