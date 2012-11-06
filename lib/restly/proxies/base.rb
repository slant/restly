require "delegate"

class Restly::Proxies::Base < SimpleDelegator

  delegate :is_a?, :kind_of?, to: :__getobj__

  # Initialize the Proxy
  def initialize(receiver)

    # Dupe the Requester
    if receiver.class == Class

      @receiver = receiver.dup

      # Some Key Methods Added to the Duplicated Requester
      @receiver.class_eval %{

        def inspect
          super.gsub(/^(#<)?#<[a-z0-9]+:([a-z0-9]+)(>)?/i, '#<#{receiver.name}:\\2')
        end

        def self.inspect
          super.gsub(/^#<[a-z0-9]+:.*/i, '#{receiver.name}')
        end

        def self.name
          "#{receiver.name}"
        end

      }
    else
      @receiver = receiver
    end

    # Initialize the Delegator
    super(@receiver)
  end

  alias_method :proxy_class, :class

  # Tell the Proxy its Class!
  def class
    @receiver.class
  end

  def proxied?
    true
  end

end