require 'api_constraints.rb'

Vindata::Application.routes.draw do

  get 'plans', :to => 'home#plans'
  get 'docs', :to => 'home#docs'
  get 'samples', :to => 'home#samples'
  get 'toc', :to => 'home#toc'
  get 'contact', :to => 'home#contact'
  get 'mobile', :to => 'home#mobile'
  get 'privacy', to: 'home#privacy'
  get 'data', to: 'home#data'
  get 'modern_categories', to: 'home#modern_categories'
  get 'classic_categories', to: 'home#classic_categories'

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :decodes
      # post 'basic'  => 'decodes#basic'
      post 'vinhunter' => 'decodes#vinhunter'
    end
    #scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
    #  resources :decodes
    #end
  end

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  mount StripeEvent::Engine => '/stripe', :as => 'stripe_engine'

  devise_for :users, :controllers => { :registrations => 'registrations', :sessions => 'sessions' }
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
  end



  get '/dashboard', :to => 'dashboard#index'
  get '/dashboard/account', to: 'dashboard#account'
  resources :charges



  resources :batches


  resources :users
  resources :decodes
  resources :item_options
  resources :categories
  resources :items
  resources :vehicles
  post 'bulk' => 'patterns#bulk', as: :bulk

  resources :patterns

  root 'home#index'

end
