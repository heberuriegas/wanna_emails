WannaEmails::Application.routes.draw do
  resources :campaigns

  resources :emails

  resources :projects do
    resources :recollections
  end

  root :to => "projects#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  authenticate :user, lambda { |u| u.admin? } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end