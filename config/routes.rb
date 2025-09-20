Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :v1 do
    resources :sessions, only: :create

    resources :sleep_records, only: [ :index ] do
      post :clock_in, on: :collection
      post :clock_out, on: :collection
    end

    scope "/users" do
      post "follow", to: "follows#create"
      delete "unfollow", to: "follows#destroy"
    end
  end
end
