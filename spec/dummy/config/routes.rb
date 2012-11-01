Dummy::Application.routes.draw do
  root to: "sample_objects#index"
  resources :sample_objects
  namespace :api, format: :json do
    resources :sample_objects
  end
end
