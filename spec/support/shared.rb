class Contact < Restly::Base

  field :first_name
  field :last_name
  field :created_at
  field :updated_at

  has_many_resources :comments
  has_many_resources :posts

end

class Post < Restly::Base

  field :title
  field :body
  field :created_at
  field :updated_at

  belongs_to_resource :contact
  has_many_resources  :comments
  has_one_resource    :rating

end

class Comment < Restly::Base

  # root_accessible false # Todo

  field :content
  field :created_at
  field :updated_at

  belongs_to_resource :contact
  embedded_in :post

end

class Rating < Restly::Base

  # root_accessible false # Todo

  field :stars
  field :count

  belongs_to :post

end