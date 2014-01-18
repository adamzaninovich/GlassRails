GlassRails::Application.routes.draw do
  get "example/index"
  get "example/add_card"
  get "example/get_location"
  get "example/delete_cards"
  get "example/show_cards"
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  root to: 'example#index'
end
