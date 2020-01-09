Rails.application.routes.draw do
  resources :books
  resources :publishing_houses
  resources :authors
  post "github_sync", to: "github_sync#create", as: :github_sync
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
