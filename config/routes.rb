# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: [:show]
  resources :todos, only: %i[index create update destroy]
end
