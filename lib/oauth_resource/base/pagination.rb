module OauthResource::Base::Pagination
  extend ActiveSupport::Concern

  included do
    rattr_accessor :pagination
  end

  module ClassMethods

    def paginates!(opts={})

      self.pagination = opts

    end

  end

  def paginates?
    !!self.class.pagination
  end

end