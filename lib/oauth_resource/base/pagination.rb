module OauthResource::Base::Pagination
  extend ActiveSupport::Concern

  included do
    rattr_accessor :pagination
  end

  module ClassMethods

    def paginates!(opts={})

      self.pagination = opts

    end

    def paginates?
      !!self.pagination
    end

  end

end