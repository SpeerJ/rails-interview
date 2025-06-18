Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create update destroy] do
      resources :todo_items, as: :items, only: %i[index create update destroy]
    end
  end

  resources :todo_lists, only: %i[index new] do
    resources :todo_items, as: :items
  end

  root 'todo_lists#index'
end
