module Restly::ConcernedInheritance
  extend ActiveSupport::Concern

  included do
    extend ClassMethods

    class_attribute :inherited_callbacks
    self.inherited_callbacks = []

    inherited do
      self.inherited_callbacks = inherited_callbacks
    end

  end

  module ClassMethods

    private

    def inherited(subclass = nil, &block)
      self.inherited_callbacks << block and return if block_given?

      inherited_callbacks.each do |call_block|
        subclass.class_eval(&call_block)
      end
    end

  end

end