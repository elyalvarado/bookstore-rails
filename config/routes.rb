Rails.application.routes.draw do
  resources :books, only: [:index, :show]
  resources :publishing_houses, only: [:index, :show]
  resources :authors, only: [:index, :show]
  post "github_sync", to: "github_sync#create", as: :github_sync
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
