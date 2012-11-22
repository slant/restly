module Restly::Base::PaginationOptions
  extend ActiveSupport::Concern

  Collection = Restly::Collection

  included do
    extend ClassMethods
    class_attribute :pagination_mapping, :pagination_options, instance_writer: false

    pagination per_page: 25

  end

  module ClassMethods

    delegate :page, to: :empty_collection

    def pagination(options={})
      # Assert Main Options
      options.assert_valid_keys :per_page, :mapping

      # Reverse Merge and Assert Mappings
      (options[:mapping] ||= {}).reverse_merge!({ current_page: :page,
                                                  per_page: :per_page,
                                                  total_pages: :total_pages,
                                                  total_entries: :total_entries })

      options[:mapping].assert_valid_keys :root, :current_page, :per_page, :total_pages, :total_entries

      # Set the options
      self.pagination_mapping = options.delete(:mapping)
      self.pagination_options = options
    end

    def empty_collection
      Collection.new(self, [])
    end

  end

end