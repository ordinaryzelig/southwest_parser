Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :searches, :only => %i[new create show] do
    collection do
      delete :destroy # until we have a Search model we can reference by ID.
    end
  end
end
