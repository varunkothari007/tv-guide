Rails.application.routes.draw do
  root 'tv_guides#index'
  resources :tv_guides, only: [:index, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
