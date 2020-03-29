Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # get '/start_game', to: 'start_game'

  root :to => "characters#start_game"
  resources :characters do
    collection do
      get :start_game
      get :home
      post :combat
    end

  end
end
