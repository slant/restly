class Restly::Base::Resource::Specification < HashWithIndifferentAccess

  attr_reader :model, :fields, :accessible_attributes

  def initialize(model)
    @model = model
    @fields = Fields.new(self)
    @accessible_attributes = AccessibleAttributes.new(self)
  end

  def [](key)
    reload! if super.nil?
    super
  end

  def reload!
    parsed_response = authorize(client_token).connection.request(:options, path).parsed
    self.replace parsed_response if parsed_response.present?
  rescue OAuth2::Error
    false
  end

  def method_missing(method, *args, &block)
    return model.send(method, *args, &block) if model.respond_to?(method)
    super
  end

  def respond_to_missing?(method, include_private=false)
    model.respond_to?(method)
  end

  module ReloadableSet

    def include?(field)
      reload! unless super
      super
    end

    def inspect
      reload! if empty?
      super
    end

    def each(*args, &block)
      reload! if empty?
      super
    end

    def map(*args, &block)
      reload! if empty?
      super
    end

    def map!(*args, &block)
      reload! if empty?
      super
    end

    def reduce(*args, &block)
      reload! if empty?
      super
    end

    def reload!
      replace []
      self
    end

  end

  class Fields < Restly::Base::Fields::FieldSet
    include ReloadableSet

    attr_reader :spec

    def initialize(spec)
      @spec = spec
      super([])
    end

    def reload!
      replace spec[:attributes]
    end

  end

  class AccessibleAttributes < ActiveModel::MassAssignmentSecurity::WhiteList
    include ReloadableSet

    attr_reader :spec

    def initialize(spec)
      @spec = spec
      super([])
    end

    def reload!
      replace spec[:actions].map { |action| action['parameters'] }.flatten if spec[:actions].present?
    end

  end

end