BaseMaterialx::Engine.routes.draw do
  resources :parts do
    collection do
      get :search
      get :search_results
      get :autocomplete
    end
  end
  
  root :to => 'parts#index'
end
