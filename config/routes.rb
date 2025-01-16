Rails.application.routes.draw do
  root :to => 'searches#new'

  get "up" => "rails/health#show", as: :rails_health_check

  resources :searches, :only => %i[new create show] do
    collection do
      delete :destroy # until we have a Search model we can reference by ID.
      post :load_cached
    end
  end
end
