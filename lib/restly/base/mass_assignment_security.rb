module Restly::Base::MassAssignmentSecurity
  extend ActiveSupport::Concern

  module ClassMethods

    def attr_accessible(*args)
      options = args.dup.extract_options!
      if options[:from_spec]
        before_initialize do
          self._accessible_attributes = spec[:actions].map { |action| action['parameters'] }.flatten
        end
      else
        super(*args)
      end
    end

  end

end