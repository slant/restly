class Api::SampleObject < ActiveRecord::Base
  attr_accessible :name, :age, :height, :weight, :gender

  has_many :other_objects
end
