module OauthResource::Base::Pagination
  extend ActiveSupport::Concern

  included do

    class_attribute :will_paginate, :pagination_opts

    self.pagination_opts = {
      params: {
        page:     :page,
        per_page: :per_page
      },
      response: {
        base: nil,
        current_page:   :current_page,
        total_entries:  :total_entries,
        total_pages:    :total_pages,
        per_page:       :per_page
      }
    }

  end

  module ClassMethods

    def paginates(opts={})
      self.will_paginate = true
      self.pagination_opts.deep_merge!(opts)
    end

  end

end