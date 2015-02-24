Rails.application.routes.draw do

  mount BaseMaterialx::Engine => "/base_materialx"
  mount Commonx::Engine => "/commonx"
  mount Authentify::Engine => '/authentify'
  mount Searchx::Engine => '/search'
  mount TwoTierDefinitionx::Engine => '/definition'
  
  
  root :to => "authentify/sessions#new"
  get '/signin',  :to => 'authentify/sessions#new'
  get '/signout', :to => 'authentify/sessions#destroy'
  get '/user_menus', :to => 'user_menus#index'
  get '/view_handler', :to => 'authentify/application#view_handler'
end
