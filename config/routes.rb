Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'works#root'
  # get '/login', to: 'sessions#login_form', as: 'login'
  # post '/login', to: 'sessions#login'
  resources :users, only: [:index, :show]
  resources :works
  post '/works/:id/upvote', to: 'works#upvote', as: 'upvote'
  post '/logout', to: 'sessions#logout', as: 'logout'
  get "/auth/:provider/callback", to: "sessions#create"
end
