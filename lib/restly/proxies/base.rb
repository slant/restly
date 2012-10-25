class Restly::Proxies::Base < SimpleDelegator

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

  # Tell the Proxy its Class!
  def class
    @receiver.class
  end

  def proxied?
    true
  end

end