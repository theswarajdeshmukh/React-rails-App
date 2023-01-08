# frozen_string_literal: true

Rails.application.routes.draw do
  constraints(lambda { |req| req.format == :json }) do
    resources :tasks, except: %i[new edit], param: :slug
    resources :users, only: %i[index create]
    resource :session, only: [:create, :destroy]
    resources :comments, only: :create
  end
  # Using lambda {|req| req.format==:json} as the constraint will make sure that
  # only JSON requests will match with the resources listed in the block.

  root "home#index"
  get "*path", to: "home#index", via: :all
end
