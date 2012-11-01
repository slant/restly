class Api::OtherObject < ActiveRecord::Base

  attr_accessible :sample_object, :sample_object_id, :foo_var, :bar_lee

  belongs_to :sample_object

end
