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
    end
  end

  def attr_reader(*args)
    args.each do |arg|
      instance_eval %{
        def #{arg}
          @#{arg}
        end
      }
    end
  end

  def attr_writer(*args)
    args.each do |arg|
      instance_eval %{
        def #{arg}=(value)
          @#{arg} = value
        end
      }
    end
  end

end