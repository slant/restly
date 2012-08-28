module OauthResource::Base::ObjectMethods

  def self.extended(base)

    def method_missing(m, *args, &block)
      if self.kind_of?(Hash) && self.with_indifferent_access.has_key?(m)
        if self.with_indifferent_access[m].kind_of?(Hash)
          self.with_indifferent_access[m].extend OauthResource::Base::ObjectMethods
        else
          self.with_indifferent_access[m]
        end
      elsif @_attributes_ && @_attributes_.with_indifferent_access.has_key?(m)
        if @_attributes_.with_indifferent_access[m].kind_of?(Hash)
          @_attributes_.with_indifferent_access[m].extend OauthResource::Base::ObjectMethods
        else
          @_attributes_.with_indifferent_access[m]
        end
      elsif m.to_s =~ /=$/ && args.size == 1
        @_attributes_ ||= {}.with_indifferent_access
        @_attributes_[m.to_s.gsub(/=$/,'').to_sym] = args.first
      else
        super
      end
    end

  end

end