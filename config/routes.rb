# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'projects#index'
  resources :projects, only: %i[index show]
  get 'projects/:organization_id/dashboard', to: 'projects#simple'

  namespace 'api' do
    resources :deploy_blocks, only: [:index]
  end
end
