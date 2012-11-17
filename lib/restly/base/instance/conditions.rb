module Restly::Base::Instance::Conditions

  def ==(object)
    reload!
    object.reload!

    this_object = Marshal.dump attributes.except(:id, :created_at, :updated_at)
    other_object = Marshal.dump object.attributes.except(:id, :created_at, :updated_at)

    Marshal.dump(this_object) == Marshal.dump(other_object) && self.class == object.class
  end

end