Rails.application.routes.draw do
  root :to => redirect('/stocks')

  resources :stocks
end
