BaseMaterialx::Engine.routes.draw do
  resources :parts do
    collection do
      get :search
      get :search_results
      get :autocomplete
      get :autocomplete_part_num
      get :autocomplete_name
    end
  end
  
  root :to => 'parts#index'
end
