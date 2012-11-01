class SampleObject < Restly::Base

  self.path = "/api/sample_objects"

  has_many_resources :other_objects

  field :name
  field :age
  field :weight
  field :height
  field :gender
  field :created_at
  field :updated_at

end