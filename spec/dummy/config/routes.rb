Rails.application.routes.draw do

  mount BaseMaterialx::Engine => "/base_materialx"
  mount Commonx::Engine => "/commonx"
  mount Authentify::Engine => '/authentify'
  mount Searchx::Engine => '/search'
  mount TwoTierDefinitionx::Engine => '/definition'
  
  
  root :to => "sessions#new", controller: :authentify
  get '/signin',  :to => 'sessions#new', controller: :authentify
  get '/signout', :to => 'sessions#destroy', controller: :authentify
  get '/user_menus', :to => 'user_menus#index', controller: :main_app
  get '/view_handler', :to => 'application#view_handler', controller: :authentify
end
