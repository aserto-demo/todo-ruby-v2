# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: [:show], constraints: { id: %r{[^/]+} }
  resources :todos, only: %i[index create update destroy], constraints: { id: %r{[^/]+} }
end
