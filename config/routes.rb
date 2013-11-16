WannaEmails::Application.routes.draw do
  resources :senders

  resources :emails

  resources :projects do
    resources :recollections
    resources :campaigns
    #resources :pages
    resources :messages
    resources :recollection_pages, only: [:index, :destroy]
  end

  root :to => "projects#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  authenticate :user, lambda { |u| u.admin? } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end