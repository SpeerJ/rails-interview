Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create update destroy]
  end

  resources :todo_lists, only: %i[index new] do
    resources :todo_items
  end
end
