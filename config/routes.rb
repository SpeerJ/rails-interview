Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create update destroy] do
      resources :todo_items, only: %i[index create update destroy]
    end
  end

  resources :todo_lists, only: %i[index new] do
    resources :todo_items do
      member do
        patch :toggle_completion
      end
      collection do
        patch :toggle_all_completed
      end
    end
  end

  root 'todo_lists#index'
end
