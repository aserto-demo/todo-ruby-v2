# frozen_string_literal: true

Rails.application.routes.draw do
  get "user/:id", controller: :users, action: :show
  get "todos", controller: :todos, action: :index
  get "todo/:ownerID", controller: :todos, action: :show
  post "todo", controller: :todos, action: :create
  put "todo/:ownerID", controller: :todos, action: :update
  delete "todo/:ownerID", controller: :todos, action: :destroy
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
