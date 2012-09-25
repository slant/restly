class OauthResource::BaseProxy < SimpleDelegator

  # Initialize the Proxy
  def initialize(requester)

    # Dupe the Requester
    @requester = requester.dup

    # Some Key Methods Added to the Duplicated Requester
    @requester.class_eval %{

      def inspect
        super.gsub(/^(#<)?#<[a-z0-9]+:([a-z0-9]+)(>)?/i, '#<#{requester.name}:\\2')
      end

      def self.inspect
        super.gsub(/^#<[a-z0-9]+:.*/i, '#{requester.name}')
      end

      def self.name
        "#{requester.name}"
      end

    }

    # Initialize the Delegator
    super(@requester)
  end

  # Tell the Proxy its Class!
  def class
    @requester
  end

end