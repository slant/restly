module Restly::Base::Resource::Specification::MassAssignmentSecurity

  class DynamicAuthorizer < Restly::Proxies::Base

    attr_reader :spec

    def initialize(spec)
      @spec = spec
      super({ default: ActiveModel::MassAssignmentSecurity::BlackList.new })
    end

    private

    def method_missing(m, *args, &block)

      # Try to set the proper authorizer!
      if spec.accessible_attributes.present?
        __setobj__ ({ default: spec.accessible_attributes })

      elsif spec.protected_attributes.present?
        __setobj__ ({ default: spec.protected_attributes })

      end

      super
    end

  end

  class AccessibleAttributes < Restly::Proxies::Base

    attr_reader :spec

    def initialize(spec)
      @spec = spec
      super ActiveModel::MassAssignmentSecurity::WhiteList.new
    end

    private

    def method_missing(m, *args, &block)
      reload_specification! unless super.present?
      super
    end

    def reload_specification!
      accepts = spec.actions.map { |action| action['accepts_parameters'] }.flatten if spec.actions.present?
      __setobj__ ActiveModel::MassAssignmentSecurity::BlackList.new accepts
    end

  end

  class ProtectedAttributes < Restly::Proxies::Base

    attr_reader :spec

    def initialize(spec)
      @spec = spec
      super ActiveModel::MassAssignmentSecurity::BlackList.new
    end

    private

    def method_missing(m, *args, &block)
      reload_specification! unless super.present?
      super
    end

    def reload_specification!
      rejects = spec.actions.map { |action| action['rejects_parameters'] }.flatten if spec.actions.present?
      __setobj__ ActiveModel::MassAssignmentSecurity::BlackList.new rejects
    end

  end

end