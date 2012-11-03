module Restly::Base::Resource::BatchActions

  def destroy_all
    !all.map(&:destroy).include?(false)
  end

  def delete_all
    !all.map(&:delete).include?(false)
  end

  def update_all(attributes={})
    all.map{ |item| item.update_attributes(attributes) }
  end

end