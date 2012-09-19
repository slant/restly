module OauthResource::BaseProxy::InstanceClassMethods

  def attr_accessor(*args)
    args.each do |arg|
      instance_eval %{
        def #{arg}=(value)
          @#{arg} = value
        end

        def #{arg}
          @#{arg}
        end
      }
      send(:"#{arg}=", requester.send(arg))
    end
  end

end