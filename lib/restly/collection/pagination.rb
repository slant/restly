module Restly::Collection::Pagination
  extend ActiveSupport::Concern

  included do
    delegate :pagination_options, :pagination_mapping, to: :resource
  end

  def paginates?
    !!current_page
  end

  def page(num, options={})
    num = 1 unless (num = num.to_i) > 0
    options.assert_valid_keys(:per_page)
    per_page = (options[:per_page] || pagination_options[:per_page]).to_i
    resource.with_params(page: num, per_page: per_page).all
  end

  private

  def method_missing(m, *args, &block)
    mapping = pagination_mapping[m]
    if pagination.has_key? mapping
      raise ArgumentError, "doesn't accept arguments" if args.present?
      pagination[mapping].try(:to_i)
    else
      super
    end
  end

  def respond_to_missing?(m, include_private = false)
    mapping = pagination_mapping[m]
    pagination.has_key? mapping
  end

  def pagination
    return {} unless response.parsed.is_a? Hash
    if (root = pagination_mapping[:root])
      response.parsed[root.to_sym] || response.parsed[root.to_s] || {}
    else
      pagination_keys = pagination_mapping.values.compact.map do |key|
        [key.to_s, key.to_sym]
      end.flatten
      response.parsed.slice(*pagination_keys)
    end.with_indifferent_access
  end

end